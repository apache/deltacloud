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
module CIMI::Collections
  class ForwardingGroups < Base

    set :capability, lambda { |m| driver.respond_to? m }

    collection :forwarding_groups do

      operation :index, :with_capability => :forwarding_groups do
        description 'List all ForwardingGroups in the ForwardingGroupsCollection'
        param :CIMISelect, :string, :optional
        control do
          forwarding_groups = ForwardingGroup.list(self).filter_by(params[:CIMISelect])
          respond_to do |format|
            format.xml {forwarding_groups.to_xml}
            format.json {forwarding_groups.to_json}
          end
        end
      end

      operation :show, :with_capability => :forwarding_groups do
        description 'Show a specific ForwardingGroup'
        control do
          forwarding_group = ForwardingGroup.find(params[:id], self)
          respond_to do |format|
            format.xml {forwarding_group.to_xml}
            format.json {forwarding_group.to_json}
          end
        end
      end

    end

  end
end
