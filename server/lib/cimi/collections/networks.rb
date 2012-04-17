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
  class Networks < Base

    check_capability :for => lambda { |m| driver.respond_to? m }

    collection :networks do
      description 'A Network represents an abstraction of a layer 2 broadcast domain'

      operation :index do
        description "List all Networks"
        param :CIMISelect,  :string,  :optional
        control do
          networks = NetworkCollection.default(self).filter_by(params[:CIMISelect])
          respond_to do |format|
            format.xml { networks.to_xml }
            format.json { networks.to_json }
          end
        end
      end

      operation :show do
        description "Show a specific Network"
        control do
          network = Network.find(params[:id], self)
          respond_to do |format|
            format.xml { network.to_xml }
            format.json { network.to_json }
          end
        end
      end

      operation :create do
        description "Create a new Network"
        control do
          if request.content_type.end_with?("json")
            network = Network.create(request.body.read, self, :json)
          else
            network = Network.create(request.body.read, self, :xml)
          end
          respond_to do |format|
            format.xml { network.to_xml}
            format.json { network.to_json }
          end
        end
      end

      operation :destroy do
        description "Delete a specified Network"
        param :id, :string, :required
        control do
          Network.delete!(params[:id], self)
          no_content_with_status(200)
        end
      end

      action :start do
        description "Start specific network."
        control do
          network = Network.find(params[:id], self)
          report_error(404) unless network
          if request.content_type.end_with?("json")
            action = Action.from_json(request.body.read)
          else
            action = Action.from_xml(request.body.read)
          end
          network.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      action :stop do
        description "Stop specific network."
        control do
          network = Network.find(params[:id], self)
          report_error(404) unless network
          if request.content_type.end_with?("json")
            action = Action.from_json(request.body.read)
          else
            action = Action.from_xml(request.body.read)
          end
          network.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      action :suspend do
        description "Suspend specific network."
        control do
          network = Network.find(params[:id], self)
          report_error(404) unless network
          if request.content_type.end_with?("json")
            action = Action.from_json(request.body.read)
          else
            action = Action.from_xml(request.body.read)
          end
          network.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

    end

  end
end
