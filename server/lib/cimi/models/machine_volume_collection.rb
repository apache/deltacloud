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
class CIMI::Model::MachineVolumeCollection < CIMI::Model::Base

  text :count

  self.schema.add_collection_member_array(CIMI::Model::MachineVolume)

  array :operations do
    scalar :rel, :href
  end

  def self.default(instance_id, context)
    volumes = CIMI::Model::MachineVolume.find(instance_id, context)
    self.new(
      :id => context.machine_url(instance_id)+"/volumes",
      :description => "MachineVolumeCollection for Machine #{instance_id}",
      :count => volumes.size,
      :machine_volumes => volumes
    )
  end
end
