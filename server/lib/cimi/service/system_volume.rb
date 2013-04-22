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

class CIMI::Service::SystemVolume < CIMI::Service::Base

  def self.find(system_id, context, id=:all)
    if id == :all
      vols = context.driver.system_volumes(context.credentials, {:env=>context, :system_id=>system_id})
      vols.collect {|e| CIMI::Service::SystemVolume.new(context, :model => e)}
    else
      vols = context.driver.system_volumes(context.credentials, {:env=>context, :system_id=>system_id, :id=>id})
      raise CIMI::Model::NotFound if vols.empty?
      CIMI::Service::SystemVolume.new(context, :model => vols.first)
    end
  end

  def self.collection_for_system(system_id, context)
    system_volumes = self.find(system_id, context)
    volumes_url = context.system_volumes_url(system_id) if context.driver.has_capability? :add_volumes_to_system
    CIMI::Model::SystemVolume.list(volumes_url, system_volumes, :add_url => volumes_url)
  end

end
