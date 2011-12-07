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

class CIMI::Frontend::Volume < CIMI::Frontend::Entity

  get '/cimi/volumes/:id' do
    volume_xml = get_entity('volumes', params[:id], credentials)
    @volume = CIMI::Model::Volume.from_xml(volume_xml)
    haml :'volumes/show'
  end

  get '/cimi/volumes' do
    volumes_xml = get_entity_collection('volumes', credentials)
    @volumes = CIMI::Model::VolumeCollection.from_xml(volumes_xml)
    haml :'volumes/index'
  end

end
