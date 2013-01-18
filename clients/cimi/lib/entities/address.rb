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
    @addresses = CIMI::Model::AddressCollection.from_xml(addresses_xml)
    haml :'addresses/index'
  end

end
