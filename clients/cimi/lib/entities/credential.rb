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

class CIMI::Frontend::Credential < CIMI::Frontend::Entity

  get '/cimi/credentials/new' do
    haml :'credentials/new'
  end

  get '/cimi/credentials/:id' do
    credentials_xml = get_entity('credentials', params[:id], credentials)
    @cred = CIMI::Model::Credential.from_xml(credentials_xml)
    haml :'credentials/show'
  end

  delete '/cimi/credentials/:id/delete' do
    result = destroy_entity('credentials', params[:id], credentials)
    if result.code == 200
      flash[:success] = "Credential '#{params[:id]}' was successfully destroyed."
      redirect '/cimi/credentials'
    else
      flash[:error] = "Unable to destroy Credential #{params[:id]}"
    end
  end

  get '/cimi/credentials' do
    credential_xml = get_entity_collection('credentials', credentials)
    @creds = collection_class_for(:credential).from_xml(credential_xml)
    haml :'credentials/index'
  end

  post '/cimi/credential' do
    credential_xml = Nokogiri::XML::Builder.new do |xml|
      xml.CredentialCreate(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.name params[:credential][:name]
        xml.description params[:credential][:description]
        xml.username params[:credential][:username]
        xml.password params[:credential][:password]
        xml.key params[:credential][:key]
      }
    end.to_xml
    begin
      result = create_entity('credentials', credential_xml, credentials)
      cred = collection_class_for(:credential).from_xml(result)
      flash[:success] = "Credential was successfully created."
      redirect "/cimi/credentials/#{href_to_id(cred.id)}", 302
    rescue => e
      flash[:error] = "Credential could not be created: #{e.message}"
      redirect(back)
    end
  end


end
