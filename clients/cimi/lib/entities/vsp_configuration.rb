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

class CIMI::Frontend::VSPConfiguration < CIMI::Frontend::Entity

  get '/cimi/vsp_configurations/:id' do
    vsp_config_xml = get_entity('vsp_configurations', params[:id], credentials)
    @vsp_config = CIMI::Model::VSPConfiguration.from_xml(vsp_config_xml)
    haml :'vsp_configurations/show'
  end

  get '/cimi/vsp_configurations' do
    vsp_configs_xml = get_entity_collection('vsp_configurations', credentials)
    @vsp_configs = collection_class_for(:vsp_configuration).from_xml(vsp_configs_xml)
    haml :'vsp_configurations/index'
  end

end
