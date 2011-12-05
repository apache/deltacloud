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

class CIMI::Frontend::VolumeImage < CIMI::Frontend::Entity

  get '/cimi/volume_images/:id' do
    volume_image_xml = CIMI::Frontend.get_entity('volume_images', params[:id], credentials)
    @volume_image= CIMI::Model::VolumeImage.from_xml(volume_image_xml)
    haml :'volume_images/show'
  end

  get '/cimi/volume_images' do
    volume_images_xml = CIMI::Frontend.get_entity_collection('volume_images', credentials)
    @volume_images = CIMI::Model::VolumeImageCollection.from_xml(volume_images_xml)
    haml :'volume_images/index'
  end

end