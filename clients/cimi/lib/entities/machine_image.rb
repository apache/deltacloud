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

class CIMI::Frontend::MachineImage < CIMI::Frontend::Entity

  get '/cimi/machine_images/:id' do
    machine_image_xml = get_entity('machine_images', params[:id], credentials)
    @machine_image= CIMI::Model::MachineImage.from_xml(machine_image_xml)
    haml :'machine_images/show'
  end

  get '/cimi/machine_images' do
    machine_image_xml = get_entity_collection('machine_images', credentials)
    @machine_images = collection_class_for(:machine_image).from_xml(machine_image_xml)
    haml :'machine_images/index'
  end

end
