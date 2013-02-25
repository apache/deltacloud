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

class CIMI::Frontend::Network < CIMI::Frontend::Entity

  get '/cimi/networks/:id' do
    network_xml = get_entity('networks', params[:id], credentials)
    @network = CIMI::Model::Network.from_xml(network_xml)
    haml :'networks/show'
  end

  get '/cimi/networks' do
    forwarding_groups_xml = get_entity_collection('forwarding_groups', credentials)
    @forwarding_groups = CIMI::Model::ForwardingGroupCollection.from_xml(forwarding_groups_xml)
    network_config_xml = get_entity_collection('network_configurations', credentials)
    @network_configurations = CIMI::Model::NetworkConfigurationCollection.from_xml(network_config_xml)
    networks_xml = get_entity_collection('networks', credentials)
    @networks = CIMI::Model::NetworkCollection.from_xml(networks_xml)
    haml :'networks/index'
  end

  post '/cimi/networks' do
    network_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Network(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.name params[:network][:name]
        xml.description params[:network][:description]
        xml.networkTemplate {
          xml.networkConfig( :href => params[:network][:network_configuration] )
          xml.forwardingGroup( :href => params[:network][:forwarding_group] )
        }
      }
    end.to_xml
    begin
      result = create_entity('networks', network_xml, credentials)
      network = CIMI::Model::NetworkCollection.from_xml(result)
      flash[:success] = "Network was successfully created."
      redirect "/cimi/networks/#{network.name}", 302
    rescue => e
      flash[:error] = "Network cannot be created: #{e.message}"
    end
  end

end
