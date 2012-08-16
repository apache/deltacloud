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
  class RoutingGroups < Base

    set :capability, lambda { |m| driver.respond_to? m }

    collection :routing_groups do

      operation :index, :with_capability => :routing_groups do
        description 'List all RoutingGroups in the RoutingGroupsCollection'
        param :CIMISelect, :string, :optional
        control do
          routing_groups = RoutingGroupCollection.default(self).filter_by(params[:CIMISelect])
          respond_to do |format|
            format.xml {routing_groups.to_xml}
            format.json {routing_groups.to_json}
          end
        end
      end

      operation :show, :with_capability => :routing_group do
        description 'Show a specific RoutingGroup'
        control do
          routing_group = RoutingGroup.find(params[:id], self)
          respond_to do |format|
            format.xml {routing_group.to_xml}
            format.json {routing_group.to_json}
          end
        end
      end

    end

  end
end
