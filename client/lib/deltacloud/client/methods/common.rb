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
    module Common

      # A generic method for creating a new resources
      #
      # - resource_name -> A resource name to create (eg. :image)
      # - create_opts -> HTTP options to pass into the create operation
      #
      def create_resource(resource_name, create_opts={})
        no_convert_model = create_opts.delete(:no_convert_model)
        must_support! resource_name.to_s.pluralize
        response = connection.post(api_uri(resource_name.to_s.pluralize)) do |request|
          request.params = create_opts
        end
        no_convert_model ? response : model(resource_name).convert(self, response.body)
      end

      # A generic method for destroying resources
      #
      def destroy_resource(resource_name, resource_id)
        must_support! resource_name.to_s.pluralize
        result = connection.delete(
          api_uri([resource_name.to_s.pluralize, resource_id].join('/'))
        )
        result.status.is_no_content?
      end

    end
  end
end
