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

class CIMI::Frontend::Machine < CIMI::Frontend::Entity

  get '/cimi/machines/:id' do
    machine_xml = get_entity('machines', params[:id], credentials)
    @machine= CIMI::Model::Machine.from_xml(machine_xml)
    haml :'machines/show'
  end

  get '/cimi/machines/:id/disks' do
    machine_xml = get_entity('machines', params[:id], credentials)
    @machine= CIMI::Model::Machine.from_xml(machine_xml)
    @disks = @machine.disks
    haml :'machines/disks/index'
  end

  get '/cimi/machines/:id/volumes' do
    machine_xml = get_entity('machines', params[:id], credentials)
    @machine= CIMI::Model::Machine.from_xml(machine_xml)
    @volumes = @machine.volumes
    haml :'volumes/index'
  end

  get '/cimi/machines' do
    # We need to include this stuff for new Machine Form
    machine_image_xml = get_entity_collection('machine_images', credentials)
    @machine_images = collection_class_for(:machine_image).from_xml(machine_image_xml)
    machine_conf_xml = get_entity_collection('machine_configurations', credentials)
    @machine_configurations = collection_class_for(:machine_configuration).from_xml(machine_conf_xml)
    begin
      credentials_xml = get_entity_collection('credentials', credentials)
      @creds = collection_class_for(:credential).from_xml(credentials_xml)
      # In case backend does not support Credential collection
    rescue RestClient::ResourceNotFound
      @creds = []
    end
    machine_xml = get_entity_collection('machines', credentials)
    @machines = collection_class_for(:machine).from_xml(machine_xml)
    haml :'machines/index'
  end

  delete '/cimi/machines/:id/delete' do
    result = destroy_entity('machines', params[:id], credentials)
    if result.code == 200
      flash[:success] = "Machine '#{params[:id]}' was successfully destroyed."
      redirect '/cimi/machines'
    else
      flash[:error] = "Unable to destroy machine #{params[:id]}"
    end
  end

  post '/cimi/machines/:id/stop' do
    action_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Action(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.action "http://schemas.dmtf.org/cimi/1/action/stop"
      }
    end.to_xml
    entity_action 'machines', 'stop', action_xml, credentials, params[:id]
    flash[:success] = "Machine successfully stopped."
    redirect '/cimi/machines/%s' % params[:id]
  end

  post '/cimi/machines/:id/start' do
    action_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Action(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.action "http://schemas.dmtf.org/cimi/1/action/start"
      }
    end.to_xml
    entity_action 'machines', 'start', action_xml, credentials, params[:id]
    flash[:success] = "Machine successfully started."
    redirect '/cimi/machines/%s' % params[:id]
  end

  post '/cimi/machines/:id/restart' do
    action_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Action(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.action "http://schemas.dmtf.org/cimi/1/action/restart"
      }
    end.to_xml
    entity_action 'machines', 'restart', action_xml, credentials, action_xml
    flash[:success] = "Machine successfully restarted."
    redirect '/cimi/machines/%s' % params[:id]
  end

  post '/cimi/machines' do
    machine_xml = Nokogiri::XML::Builder.new do |xml|
      xml.MachineCreate(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.name params[:machine][:name]
        xml.description params[:machine][:description]
        xml.machineTemplate {
          xml.machineConfig( :href => params[:machine][:machine_configuration] )
          xml.machineImage( :href => params[:machine][:machine_image] )
          xml.credential( :href => params[:machine][:credential] ) unless params[:machine][:credential].nil?
        }
      }
    end.to_xml
    begin
      result = create_entity('machines', machine_xml, credentials)
      machine = collection_class_for(:machine).from_xml(result)
      flash[:success] = "Machine was successfully created."
      redirect "/cimi/machines/#{href_to_id machine.id}", 302
    rescue => e
      flash[:error] = "Machine cannot be created: #{e.message}"
    end
  end

end
