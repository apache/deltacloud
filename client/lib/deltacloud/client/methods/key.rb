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
    module Key

      # Retrieve list of all key entities
      #
      # - filter_opts:
      #   - :id -> Filter entities using 'id' attribute
      #
      def keys(filter_opts={})
        from_collection :keys,
          connection.get(api_uri('keys'), filter_opts)
      end

      # Retrieve the single key entity
      #
      # - key_id -> Key entity to retrieve
      #
      def key(key_id)
        from_resource :key,
          connection.get(api_uri("keys/#{key_id}"))
      end

      # Create a new credentials to use with authentication
      # to an +Instance+
      #
      # - key_name -> The name of the key
      # - create_opts
      #   : public_key -> Your SSH public key (eg. ~/.ssh/id_rsa.pub)
      #
      def create_key(key_name, create_opts={})
        create_resource :key, create_opts.merge(:name => key_name)
      end

      # Destroy the SSH key
      #
      def destroy_key(key_id)
        destroy_resource :key, key_id
      end

    end
  end
end
