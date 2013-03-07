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
  class StorageSnapshot < Base

    include Deltacloud::Client::Methods::StorageSnapshot
    include Deltacloud::Client::Methods::StorageVolume

    # Inherited attributes: :_id, :name, :description

    # Custom attributes:
    #
    attr_reader :created
    attr_reader :storage_volume_id

    # StorageSnapshot model methods
    #
    def storage_volume
      super(storage_volume_id)
    end

    # Syntax sugar for destroying the current instance
    # of StorageSnapshot
    #
    def destroy!
      destroy_storage_snapshot(_id)
    end


    # Parse the StorageSnapshot entity from XML body
    #
    # - xml_body -> Deltacloud API XML representation of the storage_snapshot
    #
    def self.parse(xml_body)
      {
        :created => xml_body.text_at(:created),
        :storage_volume_id => xml_body.attr_at('storage_volume', :id)
      }
    end
  end
end
