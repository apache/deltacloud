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

# Model to store the hardware profile applied to an instance together with
# any instance-specific overrides

class InstanceAddress
  attr_accessor :address
  attr_accessor :port
  attr_accessor :address_type

  def initialize(address, opts={})
    self.address = address
    self.port = opts[:port] if opts[:port]
    self.address_type = opts[:type] || :ipv4
    self
  end

  def address_type
    (address and !address.strip.empty?) ? @address_type : :unavailable
  end

  def to_s
    return ['VNC', address, port].join(':') if is_vnc?
    address
  end

  def to_hash(context)
    r = {
      :address => address,
      :type => address_type
    }
    r.merge!(:port => port) if !port.nil?
    r
  end

  def is_mac?
    address_type == :mac
  end

  def is_ipv4?
    address_type == :ipv4
  end

  def is_ipv6?
    address_type == :ipv6
  end

  def is_hostname?
    address_type == :hostname
  end

  def is_vnc?
    address_type == :vnc
  end

end
