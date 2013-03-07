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
  class Bucket < Base

    include Deltacloud::Client::Methods::Bucket
    include Deltacloud::Client::Methods::Blob

    # Inherited attributes: :_id, :name, :description

    # Custom attributes:
    #
    attr_reader :size
    attr_reader :blob_ids

    # Bucket model methods
    #
    #

    # All blobs associated with the current bucket
    # The 'bucket_id' should not be set in this case.
    #
    def blobs(bucket_id=nil)
      super(_id)
    end

    # Add a new blob to the bucket.
    # See: +create_blob+
    #
    def add_blob(blob_name, blob_data, blob_create_opts={})
      create_blob(_id, blob_name, blob_data, create_opts)
    end

    # Remove a blob from the bucket
    # See: +destroy_blob+
    #
    def remove_blob(blob_id)
      destroy_blob(_id, blob_id)
    end

    # Parse the Bucket entity from XML body
    #
    # - xml_body -> Deltacloud API XML representation of the bucket
    #
    def self.parse(xml_body)
      {
        :size => xml_body.text_at(:size),
        :blob_ids => xml_body.xpath('blob').map { |b| b['id'] }
      }
    end
  end
end
