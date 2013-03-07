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
  module Methods
    module Instance

      # Retrieve list of all instances
      #
      # Filter options:
      #
      # - :id -> Filter instances using their 'id'
      # - :state -> Filter instances by their 'state'
      # - :realm_id -> Filter instances based on their 'realm_id'
      #
      def instances(filter_opts={})
        from_collection(
          :instances,
          connection.get(api_uri('/instances'), filter_opts)
        )
      end

      # Retrieve the given instance
      #
      # - instance_id -> Instance to retrieve
      #
      def instance(instance_id)
        from_resource(
          :instance,
          connection.get(api_uri("instances/#{instance_id}"))
        )
      end

      # Create a new instance
      #
      # - image_id ->    Image to use for instance creation (img1, ami-12345, etc...)
      # - create_opts -> Various options that DC support for the current
      #                  provider.
      #
      # Returns created instance, or list of created instances or all instances.
      #
      def create_instance(image_id, create_opts={})
        r = create_resource :instance, create_opts.merge(
          :image_id => image_id,
          :no_convert_model => true
        )
        parse_create_instance(r)
      end

      # Destroy the current +Instance+
      # Returns 'true' if the response was 204 No Content
      #
      # - instance_id -> The 'id' of the Instance to destroy
      #
      def destroy_instance(instance_id)
        destroy_resource :instance, instance_id
      end

      # Attempt to change the +Instance+ state to STOPPED
      #
      # - instance_id -> The 'id' of the Instance to stop
      #
      def stop_instance(instance_id)
        instance_action :stop, instance_id
      end

      # Attempt to change the +Instance+ state to STARTED
      #
      # - instance_id -> The 'id' of the Instance to start
      #
      def start_instance(instance_id)
        instance_action :start, instance_id
      end

      # Attempt to reboot the +Instance+
      #
      # - instance_id -> The 'id' of the Instance to reboot
      #
      def reboot_instance(instance_id)
        instance_action :reboot, instance_id
      end

      private

      # Avoid codu duplication ;-)
      #
      def instance_action(action, instance_id)
        result = connection.post(
          api_uri("/instances/#{instance_id}/#{action}")
        )
        if result.status.is_ok?
          from_resource(:instance, result)
        else
          instance(instance_id)
        end
      end

      # Handles parsing of +create_instance+ method
      #
      # - response -> +create_instance+ HTTP response body
      #
      def parse_create_instance(response)
        # If Deltacloud API return only Location (30x), follow it and
        # retrieve created instance from there.
        #
        if response.status.is_redirect?
          # If Deltacloud API redirect to list of instances
          # then return list of **all** instances, otherwise
          # grab the instance_id from Location header
          #
          redirect_instance = response.headers['Location'].split('/').last
          if redirect_instance == 'instances'
            instances
          else
            instance(redirect_instance)
          end
        elsif response.body.to_xml.root.name == 'instances'
          # If more than 1 instance was created, return list
          #
          from_collection(:instances, response.body)
        else
          from_resource(:instance, response)
        end
      end

    end
  end
end
