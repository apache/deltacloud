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
  module Helpers
    module Model

      # Retrieve the class straight from
      # Deltacloud::Client model.
      #
      # -name -> A class name in underscore form (:storage_volume)
      #
      def model(name)
        if name.nil? or (!name.nil? and name.empty?)
          raise error.new("The model name can't be blank")
        end
        Deltacloud::Client.const_get(name.to_s.camelize)
      end

      # Syntax sugar method for retrieving various Client
      # exception classes.
      #
      # - name -> Exception class name in underscore
      #
      # NOTE: If name is 'nil' the default Error exception
      #       will be returned
      #
      def error(name=nil)
        model(name || :error)
      end

      # Checks if current @connection support +model_name+
      # and then convert HTTP response to a Ruby model
      #
      # - model_name -> A class name in underscore form
      # - collection_body -> HTTP body of collection
      #
      def from_collection(model_name, collection_body)
        must_support!(model_name)
        model(model_name.to_s.singularize).from_collection(
          self,
          collection_body
        )
      end

      # Check if the collection for given model is supported
      # in current @connection and then parse/convert
      # resource XML to a Ruby class
      #
      def from_resource(model_name, resource_body)
        must_support!(model_name.to_s.pluralize)
        model(model_name).convert(self, resource_body)
      end

    end
  end
end
