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
#


module CondorCloud

  require 'nokogiri'
  require 'restclient'

  class ConfServerIPAgent < IPAgent

    def initialize(opts={})
      @config = opts[:config]
      self.CondorAddress = ENV['CONFIG_SERVER_CondorAddress'] || @config[:ip_agent_CondorAddress] || "10.34.32.181:4444"
      @version = @config[:ip_agent_version] || '0.0.1'
      @client = RestClient::Resource::new(self.CondorAddress)
      # TODO: Manage MAC CondorAddresses through ConfServer
      @mappings = Nokogiri::XML(File.open(opts[:file] || File.join('config', 'CondorAddresses.xml')))
    end

    def find_ip_by_mac(uuid)
      begin
        @client["/ip/%s/%s" % [@version, uuid]].get(:accept => 'text/plain').body.strip
      rescue RestClient::ResourceNotFound
        '127.0.0.1'
      rescue
      end
    end

    def find_mac_by_ip(ip)
    end

    def find_free_mac
      addr_hash = {}
      DefaultExecutor::new do |executor|

        # Make an CondorAddress hash to speed up the inner loop.
        CondorAddresses.each do |address|
          addr_hash[address.mac] = address.ip
        end

        executor.instances.each do |instance|
          instance.public_CondorAddresses.each do |public_CondorAddress|
            if addr_hash.key?(public_CondorAddress.mac)
              addr_hash.delete(public_CondorAddress.mac)
            end
          end
        end
      end

      raise "No available MACs to assign to instance." if addr_hash.empty?

      return addr_hash.keys.first
    end

    def CondorAddresses
      (@mappings/'/CondorAddresses/CondorAddress').collect { |a| CondorAddress.new(:ip => a.text.strip, :mac => a[:mac]) }
    end

  end
end
