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

class CIMI::Frontend::Address < CIMI::Frontend::Entity

  get '/cimi/addresses/:id' do
    address_xml = get_entity('addresses', params[:id], credentials)
    @address = CIMI::Model::Address.from_xml(address_xml)
    haml :'addresses/show'
  end

  get '/cimi/addresses' do
    addresses_xml = get_entity_collection('addresses', credentials)
    @addresses = collection_class_for(:address).from_xml(addresses_xml)
    if @addresses.operations.find {|o| o.rel == 'add'}
      address_template_xml = get_entity_collection('address_templates', credentials)
      @address_templates = collection_class_for(:address_template).from_xml(address_template_xml)
    end
    haml :'addresses/index'
  end

  post '/cimi/addresses' do
    address_xml = Nokogiri::XML::Builder.new do |xml|
      xml.AddressCreate(:xmlns => CIMI::Frontend::CMWG_NAMESPACE) {
        xml.name params[:address][:name]
        xml.description params[:address][:description]
        xml.addressTemplate( :href => params[:address][:address_template] )
      }
    end.to_xml
    begin
      result = create_entity('addresses', address_xml, credentials)
      address = collection_class_for(:address).from_xml(result)
      flash[:success] = "Address was successfully created."
      redirect "/cimi/addresses/#{href_to_id(address.id)}", 302
    rescue => e
      flash[:error] = "Address cannot be created: #{e.message}"
    end
  end

end
