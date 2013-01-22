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

class CIMI::Frontend::ForwardingGroupTemplate < CIMI::Frontend::Entity

  get '/cimi/forwarding_group_templates/:id' do
    fg_template_xml = get_entity('forwarding_group_templates', params[:id], credentials)
    @fg_template = CIMI::Model::ForwardingGroupTemplate.from_xml(fg_template_xml)
    haml :'forwarding_group_templates/show'
  end

  get '/cimi/forwarding_group_templates' do
    fg_templates_xml = get_entity_collection('forwarding_group_templates', credentials)
    @fg_templates = CIMI::Model::ForwardingGroupTemplateCollection.from_xml(fg_templates_xml)
    haml :'forwarding_group_templates/index'
  end

end
