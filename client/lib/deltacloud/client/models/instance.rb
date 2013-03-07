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

module Deltacloud::Client
  class Instance < Base

    include Deltacloud::Client::Methods::Common
    include Deltacloud::Client::Methods::Instance
    include Deltacloud::Client::Methods::Realm
    include Deltacloud::Client::Methods::HardwareProfile
    include Deltacloud::Client::Methods::Image

    attr_reader :realm_id
    attr_reader :owner_id
    attr_reader :image_id
    attr_reader :hardware_profile_id

    attr_accessor :state
    attr_accessor :public_addresses
    attr_accessor :private_addresses

    # Destroy the current Instance
    #
    def destroy!
      destroy_instance(_id)
    end

    # Execute +stop_instance+ method on current Instance
    #
    def stop!
      stop_instance(_id) && reload!
    end

    # Execute +start_instance+ method on current Instance
    #
    def start!
      start_instance(_id) && reload!
    end

    # Execute +reboot_instance+ method on current Instance
    #
    def reboot!
      reboot_instance(_id) && reload!
    end

    # Retrieve the +Realm+ associated with Instance
    #
    def realm
      super(realm_id)
    end

    def hardware_profile
      super(hardware_profile_id)
    end

    def image
      super(image_id)
    end

    def method_missing(name, *args)
      return self.state.downcase == $1 if name.to_s =~ /^is_(\w+)\?$/
      super
    end

    # Helper for is_STATE?
    #
    # is_running?
    # is_stopped?
    #
    def method_missing(name, *args)
      if name =~ /^is_(\w+)\?$/
        return state == $1.upcase
      end
      super
    end

    class << self

      def parse(xml_body)
        {
          :state =>               xml_body.text_at('state'),
          :owner_id =>            xml_body.text_at('owner_id'),
          :realm_id =>            xml_body.attr_at('realm', :id),
          :image_id =>            xml_body.attr_at('image', :id),
          :hardware_profile_id => xml_body.attr_at('hardware_profile', :id),
          :public_addresses => InstanceAddress.convert(
            xml_body.xpath('public_addresses/address')
          ),
          :private_addresses => InstanceAddress.convert(
            xml_body.xpath('private_addresses/address')
          )
        }
      end

    end

    # Attempt to reload :public_addresses, :private_addresses and :state
    # of the instance, after the instance is modified by calling method
    #
    def reload!
      new_instance = instance(_id)
      update_instance_variables!(
        :public_addresses => new_instance.public_addresses,
        :private_addresses => new_instance.private_addresses,
        :state => new_instance.state
      )
    end

  end
end
