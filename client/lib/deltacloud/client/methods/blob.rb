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
    module Blob

      # Retrieve a list of all blob entities from given bucket
      #
      def blobs(bucket_id=nil)
        raise error.new("The :bucket_id cannot be nil.") if bucket_id.nil?
        bucket(bucket_id).blob_ids.map { |blob_id| blob(bucket_id, blob_id) }
      end

      # Retrieve the single blob entity
      #
      # - blob_id -> Blob entity to retrieve
      #
      def blob(bucket_id, blob_id)
        model(:blob).convert(
          self,
          connection.get(api_uri("buckets/#{bucket_id}/#{blob_id}"))
        )
      end

      # Create a new blob
      #
      # - bucket_id -> A bucket ID that new blob should belong to
      # - blob_name -> A name for new blob
      # - blob_data -> Data stored in this blob
      # - create_opts
      #   - :user_metadata -> A Ruby +Hash+ with key => value metadata
      #
      def create_blob(bucket_id, blob_name, blob_data, create_opts={})
        must_support! :buckets
        create_opts.merge!(convert_meta_params(create_opts.delete(:user_metadata)))
        response = connection.post(api_uri("buckets/#{bucket_id}")) do |request|
          request.params = create_opts.merge(
            :blob_id => blob_name,
            :blob_data => blob_data
        )
        end
        model(:blob).convert(self, response.body)
      end

      # Destroy given bucket blob
      #
      def destroy_blob(bucket_id, blob_id)
        must_support! :buckets
        r = connection.delete(api_uri("buckets/#{bucket_id}/#{blob_id}"))
        r.status == 204
      end

      private

      # Convert the user_metadata into POST params compatible with
      # blob creation
      #
      # - params -> Simple Ruby +Hash+
      #
      # @return { :meta_params => COUNTER, :meta_name1 => '', :meta_value1 => ''}
      #
      def convert_meta_params(params)
        meta_params = {}
        counter = 0
        (params || {}).each do |key, value|
          counter += 1
          meta_params["meta_name#{counter}"] = key
          meta_params["meta_value#{counter}"] = value
        end
        if counter >= 1
          meta_params.merge!(:meta_params => counter.to_s)
        end
        meta_params
      end

    end
  end
end
