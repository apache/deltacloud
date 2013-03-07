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
    module Address

      # Retrieve list of all address entities
      #
      # Filter options:
      #
      # - :id -> Filter entities using 'id' attribute
      #
      def addresses(filter_opts={})
        from_collection :addresses,
        connection.get(api_uri('addresses'), filter_opts)
      end

      # Retrieve the single address entity
      #
      # - address_id -> Address entity to retrieve
      #
      def address(address_id)
        from_resource :address,
          connection.get(api_uri("addresses/#{address_id}"))
      end

      # Create a new address
      #
      def create_address
        create_resource :address, {}
      end

      def destroy_address(address_id)
        destroy_resource :address, address_id
      end

      def associate_address(address_id, instance_id)
        result = connection.post(
          api_uri("/addresses/#{address_id}/associate")
        ) do |request|
          request.params = { :instance_id => instance_id }
        end
        result.status == 202
      end

      def disassociate_address(address_id)
        result = connection.post(
          api_uri("/addresses/#{address_id}/disassociate")
        )
        result.status == 202
      end

    end
  end
end
