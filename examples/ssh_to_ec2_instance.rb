#
# Copyright (C) 2009  Red Hat, Inc.
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

require 'rubygems'
require 'net/ssh'
require 'deltacloud'
require 'socket'
require 'timeout'

# This Example will launch Fedora8 instance in EC2, create a new key and then
# push a command into it.

# Simple log wrapper to do fancy messages ;-)
def log(message, &block)
  cols, rows = `stty size`.split.map { |x| x.to_i }.reverse
  print "[%s] %-#{cols-20}s" % [Time.now.strftime("%H:%M:%S"), "#{message}..."]
  $stdout.flush
  retval = block.call
  puts "[OK]"
  return retval
end

# Method will try to connect to given IP and port.
# It will return true if this port is open.
def is_port_open?(ip, port)
  return false if ip==""
  begin
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(ip, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return false
      end
    end
  rescue Timeout::Error
  end
  return false
end

# Prepare deltacloud client
# TODO: Add your EC2 credentials here
client = DeltaCloud.new('<API_KEY>', '<API_PASS>', 'http://localhost:3001/api')

image = client.image('ami-2b5fba42') # Fedora 8
hardware_profile = client.hardware_profile('m1.small')

# First we need to create a new key
# Because of 'create' operation, full PEM key will be returned in '.pem' method
log "Creating a keypair with using name 'key1'" do
  @key = client.create_key(:name => "key1")
end

# Launch instance with key_name
log "Starting a new instance of Fedora 8" do
  @instance = client.create_instance(image.id, :key_name => @key.id, :hardware_profile => hardware_profile.id)
end

# We need to wait for instance, so we pool EC2 every 5 seconds and ask
# if instance is in RUNNING state
log "Waiting for instance to become ready" do
  while not @instance.state.eql?('RUNNING') do
    @instance = client.instance(@instance.id)
    @instance_host = @instance.public_addresses.first.strip
    sleep 5
  end
end

# Then, unfortunately, we need to wait again, for SSH port
# TODO: You need to add SSH into default security group in EC2
#       Otherwise, port 22 will be not open and this example will fail
log "Waiting for port 22 to be open" do
  while not is_port_open?(@instance_host, 22) do
    sleep 5
  end
end

@result = ""

# If everything is running, we save PEM to filesystem and set required perms on it.
# After that we connect to instance using this key and push some command to it.
# You can also use SCP first, move some script here and launch it. Then wait for that
# script output.
log "Pushing a command into instance" do
  File.open("/tmp/.ec2_private.key", 'w') do |f|
    @key.pem.split("\n").each do |line|
      f.puts(line.strip) if line.strip.size>0
    end
  end
  FileUtils.chmod 0600, '/tmp/.ec2_private.key'
  Net::SSH.start(@instance_host, 'root', { :keys => ['/tmp/.ec2_private.key'] }) do |session|
    session.open_channel do |channel|
      channel.on_data do |ch, data|
        @result += data
      end
      channel.exec("uname -a")
      session.loop
    end
  end
end

puts "------------------------\n: #{@result}"
