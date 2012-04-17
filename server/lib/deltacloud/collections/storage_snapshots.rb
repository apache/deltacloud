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

module Deltacloud::Collections
  class StorageSnapshots < Base
    check_capability :for => lambda { |m| driver.respond_to? m }
    check_features :for => lambda { |c, f| driver.class.has_feature?(c, f) }

    new_route_for(:storage_snapshots)

    collection :storage_snapshots do
      standard_index_operation
      standard_show_operation

      operation :create, :with_capability => :create_storage_snapshot do
        param :volume_id, :string,  :required
        control do
          @storage_snapshot = driver.create_storage_snapshot(credentials, params)
          status 201  # Created
          response['Location'] = storage_snapshot_url(@storage_snapshot.id)
          show(:storage_snapshot)
        end
      end

      operation :destroy, :with_capability => :destroy_storage_snapshot do
        control do
          driver.destroy_storage_snapshot(credentials, params)
          status 204
          respond_to do |format|
            format.xml
            format.json
            format.html { redirect(storage_snapshots_url) }
          end
        end
      end
    end

  end
end
