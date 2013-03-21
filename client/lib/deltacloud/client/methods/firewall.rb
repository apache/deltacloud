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
    module Firewall

      # Retrieve list of all firewall entities
      #
      # - filter_opts:
      #   - :id -> Filter entities using 'id' attribute
      #
      def firewalls(filter_opts={})
        from_collection :firewalls,
        connection.get(api_uri('firewalls'), filter_opts)
      end

      # Retrieve the single firewall entity
      #
      # - firewall_id -> Firewall entity to retrieve
      #
      def firewall(firewall_id)
        from_resource :firewall,
          connection.get(api_uri("firewalls/#{firewall_id}"))
      end

      # Create a new firewall
      #
      # - name - Name to associate with new firewall
      # - create_opts
      #   :name -> Name of firewall
      #
      def create_firewall(name, create_opts={})
        create_resource :firewall, { :name => name }.merge(create_opts)
      end

      def destroy_firewall(firewall_id)
        destroy_resource :firewall, firewall_id
      end

      def add_firewall_rule(firewall_id, protocol, port_from, port_to, opts={})
        r = connection.post(api_uri("firewalls/#{firewall_id}/rules")) do |request|
          request.params = {
            :protocol => protocol,
            :port_from => port_from,
            :port_to => port_to
          }
          # TODO: Add support for sources
        end
        model(:firewall).convert(self, r.body)
      end

    end
  end
end
