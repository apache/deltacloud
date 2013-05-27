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

module Deltacloud

  module Runner

    class RunnerError < StandardError
      attr_reader :message
      def initialize(message)
        @message = message
        super
      end
    end

    class InstanceSSHError < RunnerError; end

    def self.execute(command, opts={})

      if opts[:credentials] and (not opts[:credentials][:password] and not opts[:private_key])
        raise RunnerError::new("Either password or key must be specified")
      end

      # First check networking and firewalling
      network = Network::new(opts[:ip], opts[:port])

      # Then check SSH availability
      ssh = SSH::new(network, opts[:credentials], opts[:private_key])

      # Finaly execute SSH command on instance
      ssh.execute(command)
    end

    class Network
      attr_accessor :ip, :port

      def initialize(ip, port)
        @ip, @port = ip, port
      end
    end

    class SSH

      attr_reader :network
      attr_accessor :credentials, :key
      attr_reader :command

      def initialize(network, credentials, key=nil)
        @network, @credentials, @key = network, credentials, key
        @result = ""
      end

      def execute(command)
        @command = command
        config = ssh_config(@network, @credentials, @key)
        username = (@credentials[:username]) ? @credentials[:username] : 'root'
        begin
          session = nil
	  # Default timeout for connecting to an instance.
	  # 20 seconds should be OK for most of connections, if you are
	  # experiencing some Exceptions with Timeouts increase this value.
	  # Please keep in mind that the HTTP request timeout is set to 60
	  # seconds, so you need to fit into this time
          Timeout::timeout(20) do
            session = Net::SSH.start(@network.ip, username, config)
          end
          session.open_channel do |channel|
            channel.on_data do |ch, data|
              @result += data
            end
            channel.exec(command)
            session.loop
          end
          session.close
        rescue Exception => e
          raise InstanceSSHError.new("#{e.class.name}: #{e.message}")
        ensure
          # FileUtils.rm(config[:keys].first) rescue nil
        end
        Deltacloud::Runner::Response.new(self, @result)
      end

      private

      def ssh_config(network, credentials, key)
        config = { :port => network.port }
        config.merge!({ :password => credentials[:password ]}) if credentials[:password]
        config.merge!({ :keys => [ keyfile(key) ] }) unless key.nil?
        config
      end

      # Right now there is no way howto pass private_key using String
      # eg. without saving key to temporary file.
      def keyfile(key)
        keyfile = Tempfile.new("ec2_private.key")
        key_material = ""
        key.split("\n").each { |line| key_material+="#{line.strip}\n" if line.strip.size>0 }
        keyfile.write(key_material) && keyfile.close
        puts "[*] Using #{keyfile.path} as private key"
        keyfile.path
      end

    end

    class Response

      attr_reader :body
      attr_reader :ssh

      def initialize(ssh, response_body)
        @body, @ssh = response_body, ssh
      end

    end

  end
end
