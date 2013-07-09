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

class CIMI::Frontend::SystemTemplate < CIMI::Frontend::Entity

  get '/cimi/system_templates/:id' do
    system_templates_xml = get_entity('system_templates', params[:id], credentials)
    @system_template = CIMI::Model::SystemTemplate.from_xml(system_templates_xml)
    haml :'system_templates/show'
  end

  get '/cimi/system_templates' do
    system_template_xml = get_entity_collection('system_templates', credentials)
    @system_templates = collection_class_for(:system_template).from_xml(system_template_xml)
    haml :'system_templates/index'
  end

  post '/cimi/system_templates/import' do
    action_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Action(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.action "http://schemas.dmtf.org/cimi/1/action/import"
        xml.source params[:system_template][:source]
      }
    end.to_xml
    entity_action 'system_templates', 'import', action_xml, credentials
    flash[:success] = "System Template import successfully initiated."
    redirect '/cimi/system_templates'
  end

  post '/cimi/system_templates/:id/export' do
    action_xml = Nokogiri::XML::Builder.new do |xml|
      xml.Action(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.action "http://schemas.dmtf.org/cimi/1/action/export"
        xml.format params[:system_template][:format]
        xml.destination params[:system_template][:destination]
      }
    end.to_xml
    result = entity_action 'system_templates', 'export', action_xml, credentials, params[:id]
    flash[:success] = "System Template export successfully initiated."
    redirect '/cimi/system_templates/%s' % params[:id]
  end

end
