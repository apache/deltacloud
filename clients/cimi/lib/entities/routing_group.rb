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

class CIMI::Frontend::RoutingGroup < CIMI::Frontend::Entity

  get '/cimi/routing_groups/:id' do
    routing_group_xml = get_entity('routing_groups', params[:id], credentials)
    @routing_group = CIMI::Model::RoutingGroup.from_xml(routing_group_xml)
    haml :'routing_groups/show'
  end

  get '/cimi/routing_groups' do
    routing_groups_xml = get_entity_collection('routing_groups', credentials)
    @routing_groups = CIMI::Model::RoutingGroupCollection.from_xml(routing_groups_xml)
    haml :'routing_groups/index'
  end

end
