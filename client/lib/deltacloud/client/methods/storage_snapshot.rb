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
    module StorageSnapshot

      # Retrieve list of all storage_snapshot entities
      #
      # - filter_options:
      #   - :id -> Filter entities using 'id' attribute
      #
      def storage_snapshots(filter_opts={})
        from_collection :storage_snapshots,
          connection.get(api_uri('storage_snapshots'), filter_opts)
      end

      # Retrieve the single storage_snapshot entity
      #
      # - storage_snapshot_id -> StorageSnapshot entity to retrieve
      #
      def storage_snapshot(storage_snapshot_id)
        from_resource :storage_snapshot,
          connection.get(api_uri("storage_snapshots/#{storage_snapshot_id}"))
      end

      # Create a new StorageSnapshot based on +volume_id+
      #
      # - volume_id -> ID of the +StorageVolume+ to create snapshot from
      # - create_opts ->
      #   - :name -> Name of the StorageSnapshot
      #   - :description -> Description of the StorageSnapshot
      #
      def create_storage_snapshot(volume_id, create_opts={})
        create_resource :storage_snapshot, create_opts.merge(:volume_id => volume_id)
      end

      # Destroy the current +StorageSnapshot+
      # Returns 'true' if the response was 204 No Content
      #
      # - snapshot_id -> The 'id' of the snapshot to destroy
      #
      def destroy_storage_snapshot(snapshot_id)
        destroy_resource :storage_snapshot, snapshot_id
      end

    end
  end
end
