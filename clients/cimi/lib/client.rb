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

module CIMI
  module Frontend
    module Client

      def client
        RestClient::Resource.new(ENV['CIMI_API_URL'])
      end

      def get_entity(entity_type, id, credentials)
        client['%s/%s' % [entity_type, id]].get(auth_header(credentials))
      end

      def get_entity_collection(entity_type, credentials)
        client[entity_type].get(auth_header(credentials))
      end

      def create_entity(entity_type, body, credentials)
        client[entity_type].post(body, auth_header(credentials).merge(:content_type => 'application/xml'))
      end

      def destroy_entity(entity_type, id, credentials)
        client["%s/%s/delete" % [entity_type, id]].delete(auth_header(credentials))
      end

      def entity_action(entity_type, action, id, body, credentials)
        client["%s/%s/%s" % [entity_type, id, action.to_s]].post(body, auth_header(credentials))
      end

      def provider_header(credentials)
        return Hash.new unless credentials.driver
        {
          :'X-Deltacloud-Driver' => credentials.driver,
          :'X-Deltacloud-Provider' => credentials.provider
        }
      end

      def auth_header(credentials)
        encoded_credentials = ["#{credentials.user}:#{credentials.password}"].pack("m0").gsub(/\n/,'')
        { :authorization => "Basic " + encoded_credentials }.merge(provider_header(credentials))
      end

    end
  end
end
