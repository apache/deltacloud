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

  def to_hash(context)
    r = {
      :id => self.id,
      :name => name,
      :state => state,
      :owner => owner_id,
      :image => { :href => context.image_url(image_id), :id => image_id, :rel => :image },
      :realm => { :href => context.realm_url(realm_id), :id => realm_id, :rel => :realm },
      :actions => actions.compact.map { |a|
        {
          :href => context.send("#{a}_instance_url", self.id),
          :rel => "#{a}",
          :method => context.instance_action_method(a)
        }
      },
      :instance_profile => {
        :id => instance_profile.id,
        :href => context.hardware_profile_url(instance_profile.id),
        :rel => :hardware_profile,
        :properties => instance_profile.overrides
      },
      :public_addresses => public_addresses.map { |addr| addr.to_hash(context) },
      :private_addresses => private_addresses.map { |addr| addr.to_hash(context) }
    }
    r.merge!(:launch_time => launch_time)
    r.merge!(:create_image => create_image) if create_image
    r.merge!(:firewalls => firewalls.map { |f| { :id => f.id, :href => context.firewall_url(f.id), :rel => :firewall }}) if firewalls
    if storage_volumes
      r.merge!(:storage_volumes => storage_volumes.map { |f| { :id => f.id, :href => context.storage_volume_url(f.id), :rel => :storage_volume }})
    end
    if context.driver.class.has_feature?(:instances, :authentication_key)
      r.merge!(:authentication => { :keyname => keyname }) if keyname
    end
    if context.driver.class.has_feature?(:instances, :authentication_password)
      r.merge!(:authentication => { :user => username, :password => password }) if user
    end
    r
  end

  def storage_volumes
    @storage_volumes || []
  end

  def can_create_image?
    self.create_image
  end

  def hardware_profile
    instance_profile
  end

  def hardware_profile=(profile)
    @instance_profile = profile
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

end
