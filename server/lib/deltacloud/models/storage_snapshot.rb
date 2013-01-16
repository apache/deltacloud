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



class StorageSnapshot < BaseModel

  attr_accessor :state
  attr_accessor :storage_volume_id
  attr_accessor :created
  attr_accessor :name
  attr_accessor :description

  def is_completed?
    state == 'completed'
  end

  def to_hash(context)
    {
      :id => self.id,
      :href => context.storage_snapshot_url(self.id),
      :state => state,
      :storage_volume => { :id => storage_volume_id, :href => context.storage_volume_url(storage_volume_id), :rel => :storage_volume },
      :created => created
    }
  end

end
