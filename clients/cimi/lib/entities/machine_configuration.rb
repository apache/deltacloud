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

class CIMI::Frontend::MachineConfiguration < CIMI::Frontend::Entity

  get '/cimi/machine_configurations/:id' do
    machine_confs_xml = CIMI::Frontend.get_entity('machine_configurations', params[:id], credentials)
    @machine_configuration = CIMI::Model::MachineConfiguration.from_xml(machine_confs_xml)
    haml :'machine_configurations/show'
  end

  get '/cimi/machine_configurations' do
    machine_conf_xml = CIMI::Frontend.get_entity_collection('machine_configurations', credentials)
    @machine_configurations = CIMI::Model::MachineConfigurationCollection.from_xml(machine_conf_xml)
    haml :'machine_configurations/index'
  end

end
