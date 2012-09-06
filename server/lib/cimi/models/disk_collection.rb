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
class CIMI::Model::DiskCollection < CIMI::Model::Base
  text :count

  #add disks array:
  self << CIMI::Model::Disk

  array :operations do
    scalar :rel, :href
  end

  def self.default(instance_id, context)
    instance = context.driver.instance(context.credentials, :id=>instance_id)
    machine_conf = CIMI::Model::MachineConfiguration.find(instance.instance_profile.name, context)
    disks = CIMI::Model::Disk.find(instance, machine_conf, context, :all)
    self.new(
      :id => context.machine_url(instance_id)+"/disks",
      :description => "DiskCollection for Machine #{instance_id}",
      :created => instance.launch_time,
      :count => disks.size,
      :disks => disks
    )
  end
end
