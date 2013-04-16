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
    module LoadBalancer

      # Retrieve list of all load_balancer entities
      #
      # Filter options:
      #
      # - :id -> Filter entities using 'id' attribute
      #
      def load_balancers(filter_opts={})
        from_collection :load_balancers,
        connection.get(api_uri('load_balancers'), filter_opts)
      end

      # Retrieve the single load_balancer entity
      #
      # - load_balancer_id -> LoadBalancer entity to retrieve
      #
      def load_balancer(load_balancer_id)
        from_resource :load_balancer,
          connection.get(api_uri("load_balancers/#{load_balancer_id}"))
      end

      # Destroy load balancer
      # Returns 'true' if the response was 204 No Content
      #
      # - load_balancer_id -> The 'id' of the LoadBalancer to destroy
      #
      def destroy_load_balancer(load_balancer_id)
        destroy_resource :load_balancer, load_balancer_id
      end

      # Create a new load_balancer
      #
      # - create_opts
      # :name               - Load Balancer name
      # :realm_id           - Load Balancer realm id
      # :listener_protocol  - Protocol to use for LB listener (HTTP or TCP)
      # :listener_balancer_port - Load Balancer port (like. 80)
      # :listener_instance_port - Instances port (like, 8080)
      #
      # Example:
      #
      #  client.create_load_balancer(:name => 'test2', :realm_id => 'us-east-1a', :listener_protocol => 'HTTP', :listener_balancer_port => '80', :listener_instance_port => '8080')
      #
      def create_load_balancer(create_opts={})
        must_support! :load_balancers
        response = connection.post(api_uri('load_balancers')) do |request|
          request.params = create_opts
        end
        model(:load_balancer).convert(self, response.body)
      end

      # Register an Instance to given Load Balancer
      #
      # load_balancer_id - Load Balancer to use
      # instance_id      - Instance to register to load balancer
      #
      def register_instance(load_balancer_id, instance_id)
        response = connection.post(api_uri("/load_balancers/#{load_balancer_id}/register")) do |request|
          request.params = { 'instance_id' => instance_id }
        end
        model(:load_balancer).convert(self, response.body)
      end

      # Unregister an Instance from given Load Balancer
      #
      # load_balancer_id - Load Balancer to use
      # instance_id      - Instance to unregister from load balancer
      #
      def unregister_instance(load_balancer_id, instance_id)
        response = connection.post(api_uri("/load_balancers/#{load_balancer_id}/unregister")) do |request|
          request.params = { 'instance_id' => instance_id }
        end
        model(:load_balancer).convert(self, response.body)
      end

    end
  end
end
