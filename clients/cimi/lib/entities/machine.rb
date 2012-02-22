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

  get '/cimi/machines/new' do
    machine_image_xml = get_entity_collection('machine_images', credentials)
    @machine_images = CIMI::Model::MachineImageCollection.from_xml(machine_image_xml)
    machine_conf_xml = get_entity_collection('machine_configurations', credentials)
    @machine_configurations = CIMI::Model::MachineConfigurationCollection.from_xml(machine_conf_xml)
    begin
      machine_admins_xml = get_entity_collection('machine_admins', credentials)
      @machine_admins = CIMI::Model::MachineAdminCollection.from_xml(machine_admins_xml)
      # In case backend does not support MachineAdmin collection
    rescue RestClient::InternalServerError
      @machine_admins = []
    end
    haml :'machines/new'
  end

  get '/cimi/machines/:id' do
    machine_xml = get_entity('machines', params[:id], credentials)
    puts machine_xml
    @machine= CIMI::Model::Machine.from_xml(machine_xml)
    haml :'machines/show'
  end

  get '/cimi/machines' do
    machine_xml = get_entity_collection('machines', credentials)
    @machines = CIMI::Model::MachineCollection.from_xml(machine_xml)
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
        xml.action "http://www.dmtf.org/cimi/action/stop"
      }
    end.to_xml
    result = entity_action(:machines, :stop, params[:id], action_xml, credentials)
    flash[:success] = "Machine successfully stopped."
    redirect '/cimi/machines/%s' % params[:id]
  end

  post '/cimi/machines/:id/start' do
    action_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Action(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.action "http://www.dmtf.org/cimi/action/start"
      }
    end.to_xml
    result = entity_action(:machines, :start, params[:id], action_xml, credentials)
    flash[:success] = "Machine successfully started."
    redirect '/cimi/machines/%s' % params[:id]
  end

  post '/cimi/machines/:id/restart' do
    action_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Action(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.action "http://www.dmtf.org/cimi/action/restart"
      }
    end.to_xml
    result = entity_action(:machines, :restart, params[:id], action_xml, credentials)
    flash[:success] = "Machine successfully restarted."
    redirect '/cimi/machines/%s' % params[:id]
  end

  post '/cimi/machines' do
    machine_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Machine(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.name params[:machine][:name]
        xml.description params[:machine][:description]
        xml.MachineTemplate {
          xml.MachineConfig( :href => params[:machine][:machine_configuration] )
          xml.MachineImage( :href => params[:machine][:machine_image] )
          xml.MachineAdmin( :href => params[:machine][:machine_admin] ) unless params[:machine][:machine_admin].empty?
        }
      }
    end.to_xml
    puts machine_xml
    begin
      result = create_entity('machines', machine_xml, credentials)
      machine = CIMI::Model::MachineCollection.from_xml(result)
      flash[:success] = "Machine was successfully created."
      redirect "/cimi/machines/#{machine.name}", 302
    rescue => e
      flash[:error] = "Machine cannot be created: #{e.message}"
      redirect :back
    end
  end

end
