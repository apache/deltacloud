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

class CIMI::Frontend::NetworkConfiguration < CIMI::Frontend::Entity

  get '/cimi/network_configurations/:id' do
    network_config_xml = get_entity('network_configurations', params[:id], credentials)
    @network_config = CIMI::Model::NetworkConfiguration.from_xml(network_config_xml)
    haml :'network_configurations/show'
  end

  get '/cimi/network_configurations' do
    network_configs_xml = get_entity_collection('network_configurations', credentials)
    @network_configs = collection_class_for(:network_configuration).from_xml(network_configs_xml)
    haml :'network_configurations/index'
  end

end
