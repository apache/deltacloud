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

module CIMI::Collections
  class VolumeImages < Base

    set :capability, lambda { |m| driver.respond_to? m }

    collection :volume_images do
      description 'This entity represents an image that could be place on a pre-loaded volume.'

      generate_index_operation :with_capability => :storage_snapshots
      generate_show_operation :with_capability => :storage_snapshot
      generate_create_operation :with_capability => :create_storage_snapshot
      generate_delete_operation :with_capability => :destroy_storage_snapshot

    end

  end
end
