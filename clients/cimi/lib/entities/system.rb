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

class CIMI::Frontend::System < CIMI::Frontend::Entity

  get '/cimi/systems' do
    system_xml = get_entity_collection('systems', credentials)
    @systems = collection_class_for(:system).from_xml(system_xml)
    # We need to include this stuff for new System form
    begin
      system_templates_xml = get_entity_collection('system_templates', credentials)
      @system_templates = collection_class_for(:system_template).from_xml(system_templates_xml)
    rescue RestClient::ResourceNotFound # In case backend does not support System Template collection
      @system_templates = nil
    end
    haml :'systems/index'
  end

  get '/cimi/systems/:id' do
    system_xml = get_entity('systems', params[:id], credentials)
    @system = CIMI::Model::System.from_xml(system_xml)
    haml :'systems/show'
  end

  get '/cimi/systems/:id/systems' do
    systems_resources_index('systems')
  end

  get '/cimi/systems/:id/machines' do
    systems_resources_index('machines')
  end

  get '/cimi/systems/:id/credentials' do
    systems_resources_index('credentials')
  end

  get '/cimi/systems/:id/volumes' do
    systems_resources_index('volumes')
  end

  get '/cimi/systems/:id/networks' do
    systems_resources_index('networks')
  end

  get '/cimi/systems/:id/network_ports' do
    systems_resources_index('network_ports')
  end

  get '/cimi/systems/:id/addresses' do
    systems_resources_index('addresses')
  end

  get '/cimi/systems/:id/forwarding_groups' do
    systems_resources_index('forwarding_groups')
  end

  get '/cimi/systems/:id/systems/:res_id' do
    systems_resources_show('systems')
  end

  get '/cimi/systems/:id/machines/:res_id' do
    systems_resources_show('machines')
  end

  get '/cimi/systems/:id/credentials/:res_id' do
    systems_resources_show('credentials')
  end

  get '/cimi/systems/:id/volumes/:res_id' do
    systems_resources_show('volumes')
  end

  get '/cimi/systems/:id/networks/:res_id' do
    systems_resources_show('networks')
  end

  get '/cimi/systems/:id/network_ports/:res_id' do
    systems_resources_show('network_ports')
  end

  get '/cimi/systems/:id/addresses/:res_id' do
    systems_resources_show('addresses')
  end

  get '/cimi/systems/:id/forwarding_groups/:res_id' do
    systems_resources_show('forwarding_groups')
  end

  def systems_resources_show(res)
    system_xml = get_entity('systems', params[:id], credentials)
    @system = CIMI::Model::System.from_xml(system_xml)
    @resource_collection = @system.send(res)
    system_resources_xml = get_sub_entity_collection(@resource_collection.href, credentials)
    @resource = XmlSimple.xml_in(system_resources_xml)[collection_name(@resource_collection).sub(/(.+)Collection/,'\1')].find do |r|
      href_to_id r['id'][0] == params[:res_id]
    end
    raise RestClient::ResourceNotFound if not @resource
    @resource_type = id_to_href(collection_name(@resource_collection).sub(/System(.+)Collection/,'\1'))[1..-1]
    haml :'systems/resources/show'
  end

  def systems_resources_index(res)
    system_xml = get_entity('systems', params[:id], credentials)
    @system = CIMI::Model::System.from_xml(system_xml)
    @resource_collection = @system.send(res)
    system_resources_xml = get_sub_entity_collection(@resource_collection.href, credentials)
    @resources = XmlSimple.xml_in(system_resources_xml)
    haml :'systems/resources/index'
  end

  delete '/cimi/systems/:id/delete' do
    result = destroy_entity('systems', params[:id], credentials)
    if result.code == 200
      flash[:success] = "System '#{params[:id]}' was successfully destroyed."
      redirect '/cimi/systems'
    elsif result.code == 202
      flash[:success] = "Deletion of System '#{params[:id]}' was successfully initiated."
      redirect '/cimi/systems'
    else
      flash[:error] = "Unable to destroy system #{params[:id]}"
    end
  end

  post '/cimi/systems/:id/stop' do
    action_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Action(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.action "http://schemas.dmtf.org/cimi/1/action/stop"
      }
    end.to_xml
    entity_action 'systems', 'stop', action_xml, credentials, params[:id]
    flash[:success] = "System stop successfully initiated."
    redirect '/cimi/systems/%s' % params[:id]
  end

  post '/cimi/systems/:id/start' do
    action_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Action(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.action "http://schemas.dmtf.org/cimi/1/action/start"
      }
    end.to_xml
    entity_action 'systems', 'start', action_xml, credentials, params[:id]
    flash[:success] = "System start successfully initiated."
    redirect '/cimi/systems/%s' % params[:id]
  end

  post '/cimi/systems/:id/restart' do
    action_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Action(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.action "http://schemas.dmtf.org/cimi/1/action/restart"
      }
    end.to_xml
    entity_action 'systems', 'restart', action_xml, credentials, params[:id]
    flash[:success] = "System restart successfully initiated."
    redirect '/cimi/systems/%s' % params[:id]
  end

  post '/cimi/systems' do
    system_xml = Nokogiri::XML::Builder.new do |xml|
      xml.SystemCreate(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.name params[:system][:name]
        xml.systemTemplate( :href => params[:system][:system_template])
      }
    end.to_xml
    begin
      result = create_entity('systems', system_xml, credentials)
      flash[:success] = "System create was successfully initiated."
      location = result.headers[:location]
      if location
        redirect "/cimi/systems/#{href_to_id location}"
      else
        system = collection_class_for(:system).from_xml(result)
        redirect "/cimi/systems/#{href_to_id system.id}"
      end
    rescue => e
      flash[:error] = "System cannot be created: #{e.message}"
    end
  end

  post '/cimi/systems/import' do
    action_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Action(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.action "http://schemas.dmtf.org/cimi/1/action/import"
        xml.source params[:system][:source]
      }
    end.to_xml
    entity_action 'systems', 'import', action_xml, credentials
    flash[:success] = "System import successfully initiated."
    redirect '/cimi/systems'
  end

  post '/cimi/systems/:id/export' do
    action_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Action(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.action "http://schemas.dmtf.org/cimi/1/action/export"
        xml.format params[:system][:format]
        xml.destination params[:system][:destination]
      }
    end.to_xml
    result = entity_action 'systems', 'export', action_xml, credentials, params[:id]
    flash[:success] = "System export successfully initiated."
    redirect '/cimi/systems/%s' % params[:id]
  end

end
