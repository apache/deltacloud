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

class CIMI::Model::MachineVolume < CIMI::Model::Base

  text :initial_location
  href :volume

  array :operations do
    scalar :rel, :href
  end

  def self.find(instance_id, context, id=:all)
    if id == :all
      volumes = context.driver.storage_volumes(context.credentials)
      volumes.inject([]) do |attached, vol|
        attached <<  self.new(
          :id => context.machine_url(instance_id)+"/volumes/#{vol.id}",
          :name => vol.id,
          :description => "MachineVolume #{vol.id} for Machine #{instance_id}",
          :created => vol.created,
          :initial_location => vol.device,
          :volume => {:href=>context.volume_url(vol.id)}
          ) if vol.instance_id == instance_id
        attached
      end
    else
    end
  end
end
