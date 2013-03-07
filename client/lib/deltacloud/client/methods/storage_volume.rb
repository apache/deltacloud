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
    module StorageVolume

      # Retrieve list of all storage_volumes
      #
      # Filter options:
      #
      # - :id -> Filter storage_volumes using their 'id'
      # - :state -> Filter storage_volumes  by their 'state'
      #
      def storage_volumes(filter_opts={})
        from_collection :storage_volumes,
          connection.get(api_uri("storage_volumes"), filter_opts)
      end

      # Retrieve the given storage_volume
      #
      # - storage_volume_id -> Instance to retrieve
      #
      def storage_volume(storage_volume_id)
        from_resource :storage_volume,
          connection.get(api_uri("storage_volumes/#{storage_volume_id}"))
      end

      # Create new storage volume
      #
      # - :snapshot_id -> Snapshot to use for creating a new volume
      # - :capacity    -> Initial Volume capacity
      # - :realm_id    -> Create volume in this realm
      # - :name        -> Volume name
      # - :description -> Volume description
      #
      # NOTE: Some create options might not be supported by backend cloud
      #
      def create_storage_volume(create_opts={})
        create_resource :storage_volume, create_opts
      end

      # Destroy the current +StorageVolume+
      # Returns 'true' if the response was 204 No Content
      #
      # - volume_id -> The 'id' of the volume to destroy
      #
      def destroy_storage_volume(volume_id)
        destroy_resource :storage_volume, volume_id
      end

      # Attach the Storage Volume to the Instance
      # The +device+ parameter could be used if supported.
      #
      # - volume_id -> Volume ID (eg. 'vol1')
      # - instance_id -> Target Instance ID (eg. 'inst1')
      # - device -> Target device in Instance (eg. '/dev/sda2')
      #
      def attach_storage_volume(volume_id, instance_id, device=nil)
        must_support! :storage_volumes
        result = connection.post(api_uri("/storage_volumes/#{volume_id}/attach")) do |r|
          r.params = { :instance_id => instance_id, :device => device }
        end
        if result.status.is_ok?
          from_resource(:storage_volume, result)
        end
      end

      # Detach the Storage Volume from the Instance
      #
      # -volume_id -> Volume to detach
      #
      def detach_storage_volume(volume_id)
        must_support! :storage_volumes
        result = connection.post(api_uri("/storage_volumes/#{volume_id}/detach"))
        if result.status.is_ok?
          from_resource(:storage_volume, result)
        end
      end

    end
  end
end
