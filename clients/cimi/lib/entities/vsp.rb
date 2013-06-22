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

class CIMI::Frontend::VSP < CIMI::Frontend::Entity

  get '/cimi/vsps/:id' do
    vsp_xml = get_entity('vsps', params[:id], credentials)
    @vsp = CIMI::Model::VSP.from_xml(vsp_xml)
    haml :'vsps/show'
  end

  get '/cimi/vsps' do
    vsps_xml = get_entity_collection('vsps', credentials)
    @vsps = collection_class_for(:vsp).from_xml(vsps_xml)
    haml :'vsps/index'
  end

end
