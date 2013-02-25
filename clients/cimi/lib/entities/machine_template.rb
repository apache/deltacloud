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

class CIMI::Frontend::MachineTemplate < CIMI::Frontend::Entity

  get '/cimi/machine_templates/:id' do
    machine_templates_xml = get_entity('machine_templates', params[:id], credentials)
    @machine_template = CIMI::Model::MachineTemplate.from_xml(machine_templates_xml)
    haml :'machine_templates/show'
  end

  get '/cimi/machine_templates' do
    machine_image_xml = get_entity_collection('machine_images', credentials)
    @machine_images = CIMI::Model::MachineImageCollection.from_xml(machine_image_xml)
    machine_conf_xml = get_entity_collection('machine_configurations', credentials)
    @machine_configurations = CIMI::Model::MachineConfigurationCollection.from_xml(machine_conf_xml)
    machine_template_xml = get_entity_collection('machine_templates', credentials)
    @machine_templates = CIMI::Model::MachineTemplateCollection.from_xml(machine_template_xml)
    haml :'machine_templates/index'
  end

  post '/cimi/machine_templates' do
    machine_template_xml = Nokogiri::XML::Builder.new do |xml|
      xml.MachineTemplate(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.name params[:machine_template][:name]
        xml.description params[:machine_template][:description]
        xml.machineConfig( :href => params[:machine_template][:machine_config] )
        xml.machineImage( :href => params[:machine_template][:machine_image] )
      }
    end.to_xml
    begin
      result = create_entity('machine_templates', machine_template_xml, credentials)
      machine_template = CIMI::Model::MachineTemplateCollection.from_xml(result)
      flash[:success] = "Machine Template was successfully created."
      redirect "/cimi/machine_templates/#{machine_template.name}", 302
    rescue => e
      flash[:error] = "Machine Template cannot be created: #{e.message}"
    end
  end

end
