#
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


class StorageVolume < BaseModel

  attr_accessor :created
  attr_accessor :state
  attr_accessor :capacity
  attr_accessor :instance_id
  attr_accessor :device
  attr_accessor :realm_id
  attr_accessor :actions
  attr_accessor :name
  attr_accessor :kind
  attr_accessor :description # openstack volumes have a display_description attr

  def to_hash(context)
    r = {
      :id => self.id,
      :href => context.storage_volume_url(self.id),
      :name => name,
      :description => description,
      :state => state,
      :created => created,
      :realm => { :id => realm_id, :href => context.realm_url(realm_id), :rel => :realm },
      :device => device,
      :kind => kind,
      :capacity => capacity,
    }
    r[:actions] = (actions || []).map { |a|
      { :href => context.send("#{a}_storage_volume_url", self.id), :rel => a }
    }
    if instance_id
      r[:instance] = { :id => instance_id, :href => context.instance_url(instance_id), :rel => :instance }
    else
      r[:instance] = {}
    end
    r
  end

end
