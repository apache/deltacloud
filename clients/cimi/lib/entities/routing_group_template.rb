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

class CIMI::Frontend::RoutingGroupTemplate < CIMI::Frontend::Entity

  get '/cimi/routing_group_templates/:id' do
    rg_template_xml = get_entity('routing_group_templates', params[:id], credentials)
    @rg_template = CIMI::Model::RoutingGroupTemplate.from_xml(rg_template_xml)
    haml :'routing_group_templates/show'
  end

  get '/cimi/routing_group_templates' do
    rg_templates_xml = get_entity_collection('routing_group_templates', credentials)
    @rg_templates = CIMI::Model::RoutingGroupTemplateCollection.from_xml(rg_templates_xml)
    haml :'routing_group_templates/index'
  end

end
