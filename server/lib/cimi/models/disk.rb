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

class CIMI::Model::Disk < CIMI::Model::Base

  text :capacity
  text :initial_location

  array :operations do
    scalar :rel, :href
  end

  def self.find(instance, machine_config, context, id=:all)
    if id == :all
      storage_override = instance.instance_profile.overrides.find { |p, v| p == :storage }
      capacity = storage_override.nil? ? machine_config.disks[0][:capacity] : context.to_kibibyte(storage_override[1].to_i, "MB")
      name = instance.id+"_disk_#{capacity}" #assuming one disk for now...
     [ self.new(
       :id => context.machine_url(instance.id)+"/disks/#{name}",
       :name => name,
       :description => "DiskCollection for Machine #{instance.id}",
       :created => instance.launch_time,
       :capacity => capacity
      ) ]
    else
    end
  end
end
