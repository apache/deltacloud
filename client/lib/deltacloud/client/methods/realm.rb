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
    module Realm

      # Retrieve list of all realms
      #
      # Filter options:
      #
      # - :id -> Filter realms using their 'id'
      # - :state -> Filter realms  by their 'state'
      #
      def realms(filter_opts={})
        from_collection :realms,
          connection.get(api_uri("realms"), filter_opts)
      end

      # Retrieve the given realm
      #
      # - realm_id -> Instance to retrieve
      #
      def realm(realm_id)
        from_resource :realm,
          connection.get(api_uri("realms/#{realm_id}"))
      end

    end
  end
end
