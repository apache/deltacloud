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

class CIMI::Frontend::NetworkPort < CIMI::Frontend::Entity

  get '/cimi/network_ports/:id' do
    network_port_xml = get_entity('network_ports', params[:id], credentials)
    @network_port = CIMI::Model::NetworkPort.from_xml(network_port_xml)
    haml :'network_ports/show'
  end

  get '/cimi/network_ports' do
    network_ports_xml = get_entity_collection('network_ports', credentials)
    @network_ports = CIMI::Model::NetworkPortCollection.from_xml(network_ports_xml)
    haml :'network_ports/index'
  end

end
