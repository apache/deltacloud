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

    set :capability, lambda { |m| driver.respond_to? m }

    collection :networks do
      description 'A Network represents an abstraction of a layer 2 broadcast domain'

      operation :index, :with_capability => :networks do
        description "List all Networks"
        control do
          networks = Network.list(self).filter_by(params['$select'])
          respond_to do |format|
            format.xml { networks.to_xml }
            format.json { networks.to_json }
          end
        end
      end

      operation :show, :with_capability => :networks do
        description "Show a specific Network"
        control do
          network = Network.find(params[:id], self)
          respond_to do |format|
            format.xml { network.to_xml }
            format.json { network.to_json }
          end
        end
      end

      operation :create, :with_capability => :create_network do
        description "Create a new Network"
        control do
          if grab_content_type(request.content_type, request.body) == :json
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

      operation :destroy, :with_capability => :delete_network do
        description "Delete a specified Network"
        control do
          Network.delete!(params[:id], self)
          no_content_with_status(200)
        end
      end

      action :start, :with_capability => :start_network do
        description "Start specific network."
        param :id, :string, :required
        control do
          network = Network.find(params[:id], self)
          report_error(404) unless network
          if grab_content_type(request.content_type, request.body) == :json
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

      action :stop, :with_capability => :stop_network do
        description "Stop specific network."
        param :id, :string, :required
        control do
          network = Network.find(params[:id], self)
          report_error(404) unless network
          if grab_content_type(request.content_type, request.body) == :json
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

      action :suspend, :with_capability => :suspend_network do
        description "Suspend specific network."
        param :id, :string, :required
        control do
          network = Network.find(params[:id], self)
          report_error(404) unless network
          if grab_content_type(request.content_type, request.body) == :json
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

      operation :network_ports, :with_capability => :network_ports do
        description "Retrieve the Network's NetworkPortCollection"
        param :id, :string, :required
        control do
          network_ports = NetworkPort.collection_for_network(params[:id], self)
          respond_to do |format|
            format.json {network_ports.to_json}
            format.xml  {network_ports.to_xml}
          end
        end
      end


    end

  end
end
