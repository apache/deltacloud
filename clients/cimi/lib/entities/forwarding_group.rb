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

class CIMI::Frontend::ForwardingGroup < CIMI::Frontend::Entity

  get '/cimi/forwarding_groups/:id' do
    fg_xml = get_entity('forwarding_groups', params[:id], credentials)
    @fg = CIMI::Model::ForwardingGroup.from_xml(fg_xml)
    haml :'forwarding_groups/show'
  end

  get '/cimi/forwarding_groups' do
    fgs_xml = get_entity_collection('forwarding_groups', credentials)
    @fgs = CIMI::Model::ForwardingGroupCollection.from_xml(fgs_xml)
    haml :'forwarding_groups/index'
  end

end
