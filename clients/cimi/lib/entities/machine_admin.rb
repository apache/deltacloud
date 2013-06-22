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

class CIMI::Frontend::MachineAdmin < CIMI::Frontend::Entity

  get '/cimi/machine_admins/new' do
    haml :'machine_admins/new'
  end

  get '/cimi/machine_admins/:id' do
    machine_admins_xml = get_entity('machine_admins', params[:id], credentials)
    @machine_admin = CIMI::Model::MachineAdmin.from_xml(machine_admins_xml)
    haml :'machine_admins/show'
  end

  delete '/cimi/machine_admins/:id/delete' do
    result = destroy_entity('machine_admins', params[:id], credentials)
    if result.code == 200
      flash[:success] = "MachineAdmin '#{params[:id]}' was successfully destroyed."
      redirect '/cimi/machine_admins'
    else
      flash[:error] = "Unable to destroy Machine Admin #{params[:id]}"
    end
  end

  get '/cimi/machine_admins' do
    machine_admin_xml = get_entity_collection('machine_admins', credentials)
    @machine_admins = collection_class_for(:machine_admin).from_xml(machine_admin_xml)
    haml :'machine_admins/index'
  end

  post '/cimi/machine_admin' do
    machine_admin_xml = Nokogiri::XML::Builder.new do |xml|
      xml.MachineAdmin(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.name params[:machine_admin][:name]
        xml.description params[:machine_admin][:description]
        xml.username params[:machine_admin][:username]
        xml.password params[:machine_admin][:password]
        xml.key params[:machine_admin][:key]
      }
    end.to_xml
    begin
      result = create_entity('machine_admins', machine_admin_xml, credentials)
      machine_admin = collection_class_for(:machine_admin).from_xml(result)
      flash[:success] = "MachineAdmin was successfully created."
      redirect "/cimi/machine_admins/#{machine_admin.name}", 302
    rescue => e
      flash[:error] = "Machine Admin could not be created: #{e.message}"
      redirect(back)
    end
  end


end
