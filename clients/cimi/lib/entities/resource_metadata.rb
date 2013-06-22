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

class CIMI::Frontend::ResourceMetadata < CIMI::Frontend::Entity

  get '/cimi/resource_metadata/:id' do
    resource_metadata_xml = get_entity('resource_metadata', params[:id], credentials)
    @resource_metadata = CIMI::Model::ResourceMetadata.from_xml(resource_metadata_xml)
    haml :'resource_metadata/show'
  end

  get '/cimi/resource_metadata' do
    resource_metadata_xml = get_entity_collection('resource_metadata', credentials)
    @resource_metadata = collection_class_for(:resource_metadata).from_xml(resource_metadata_xml)
    haml :'resource_metadata/index'
  end

end
