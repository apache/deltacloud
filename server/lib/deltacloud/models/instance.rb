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

require 'timeout'

class Instance < BaseModel

  include Timeout

  attr_accessor :owner_id
  attr_accessor :image_id
  attr_accessor :name
  attr_accessor :realm_id
  attr_accessor :state
  attr_accessor :actions
  attr_accessor :public_addresses
  attr_accessor :private_addresses
  attr_accessor :instance_profile
  attr_accessor :launch_time
  attr_accessor :keyname
  attr_accessor :authn_error
  attr_accessor :username
  attr_accessor :password
  attr_accessor :create_image
  attr_accessor :firewalls
  attr_accessor :storage_volumes

  def storage_volumes
    @storage_volumes || []
  end

  def can_create_image?
    self.create_image
  end

  def to_s
    name
  end

  def hardware_profile
    instance_profile
  end

  def hardware_profile=(profile)
    instance_profile = profile
  end

  def initialize(init=nil)
    super(init)
    self.actions = [] if self.actions.nil?
    self.public_addresses = [] if self.public_addresses.nil?
    self.private_addresses = [] if self.private_addresses.nil?
  end

  def method_missing(name, *args)
    if name.to_s =~ /is_(\w+)\?/
      self.state.downcase.eql?($1)
    else
      raise NoMethodError.new(name.to_s)
    end
  end

  def authn_feature_failed?
    return true unless authn_error.nil?
  end

  # This method will pool the instance until condition is true
  # Will raise 'Timeout' when it reach retry count
  #
  # default opts[:retries] => 10
  # default opts[:time_between_retry] => 10 (seconds)
  # default opts[:timeout] => 60 (seconds) -> single request timeout
  #
  # opts[:before] => Proc -> executed 'before' making each request
  # opts[:after] => Proc -> executed 'after' making each request
  #
  def wait_for!(driver, opts={}, &block)
    opts[:retries] ||= 10
    opts[:time_between_retry] ||= 10
    opts[:timeout] ||= 60
    opts[:retries].downto(0) do |r|
      result = begin
        timeout(opts[:timeout]) do
          if opts[:before]
            new_instance = opts[:before].call(r) { driver.instance(:id => self.id) }
          else
            new_instance = driver.instance(:id => self.id)
          end
          ((yield new_instance) == true) ? new_instance : false
        end
      rescue Timeout::Error
        false
      ensure
        opts[:after].call(r) if opts[:after]
      end
      return result unless result == false
      sleep(opts[:time_between_retry])
    end
    raise Timeout::Error
  end

end
