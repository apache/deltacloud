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

class CIMI::Service::SystemForwardingGroup < CIMI::Service::Base

  def self.find(system_id, context, id=:all)
    if id == :all
      groups = context.driver.system_forwarding_groups(context.credentials, {:env=>context, :system_id=>system_id})
    else
      groups = context.driver.system_forwarding_groups(context.credentials, {:env=>context, :system_id=>system_id, :id=>id})
      raise CIMI::Model::NotFound if groups.empty?
      groups.first
    end
  end

  def self.collection_for_system(system_id, context)
    system_forwarding_groups = self.find(system_id, context)
    forwarding_groups_url = context.url("/system/#{system_id}/forwarding_groups") if context.driver.has_capability? :add_forwarding_groups_to_system
    CIMI::Model::SystemForwardingGroup.list(forwarding_groups_url, system_forwarding_groups, :add_url => forwarding_groups_url)
  end

end
