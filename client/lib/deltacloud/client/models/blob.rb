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
  class Blob < Base

    include Deltacloud::Client::Methods::Blob
    include Deltacloud::Client::Methods::Bucket

    # Inherited attributes: :_id, :name, :description

    # Custom attributes:
    #
    attr_reader :bucket_id
    attr_reader :content_length
    attr_reader :content_type
    attr_reader :last_modified
    attr_reader :user_metadata

    # Blob model methods
    #

    def bucket
      super(bucket_id)
    end

    # Parse the Blob entity from XML body
    #
    # - xml_body -> Deltacloud API XML representation of the blob
    #
    def self.parse(xml_body)
      {
        :bucket_id => xml_body.text_at(:bucket_id) || xml_body.text_at(:bucket), # FIXME: DC bug
        :content_length => xml_body.text_at(:content_length),
        :content_type => xml_body.text_at(:content_type),
        :last_modified => xml_body.text_at(:last_modified),
        :user_metadata => xml_body.xpath('user_metadata/entry').inject({}) { |r,e|
          r[e['key']] = e.text.strip
          r
        }
      }
    end
  end
end
