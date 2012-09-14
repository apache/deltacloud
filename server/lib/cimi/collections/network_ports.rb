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
  class NetworkPorts < Base

    set :capability, lambda { |m| driver.respond_to? m }

    collection :network_ports do

      description 'A NetworkPort is a realized connection point between a Network and a resource - such as a Machine.'

      operation :index, :with_capability => :network_ports do
        description 'List all NetworkPorts in the NetworkPortCollection'
        param :CIMISelect, :string, :optional
        control do
          network_ports = NetworkPortCollection.default(self).filter_by(params[:CIMISelect])
          respond_to do |format|
            format.xml {network_ports.to_xml}
            format.json {network_ports.to_json}
          end
        end
      end

      operation :show, :with_capability => :network_ports do
        description 'Show a specific NetworkPort'
        control do
          network_port = NetworkPort.find(params[:id], self)
          respond_to do |format|
            format.xml {network_port.to_xml}
            format.json {network_port.to_json}
          end
        end
      end

      operation :create, :with_capability => :create_network_port do
        description "Create a new NetworkPort"
        control do
          if request.content_type.end_with?("json")
            network_port = CIMI::Model::NetworkPort.create(request.body.read, self, :json)
          else
            network_port = CIMI::Model::NetworkPort.create(request.body.read, self, :xml)
          end
          respond_to do |format|
            format.xml { network_port.to_xml }
            format.json { network_port.to_json }
          end
        end
      end

      operation :destroy, :with_capability => :delete_network_port do
        description "Delete a specified NetworkPort"
        control do
          CIMI::Model::NetworkPort.delete!(params[:id], self)
          no_content_with_status(200)
        end
      end

      action :start, :with_capability => :start_network_port do
        description "Start specific NetworkPort."
        param :id,          :string,    :required
        control do
          network_port = NetworkPort.find(params[:id], self)
          report_error(404) unless network_port
          if request.content_type.end_with?("json")
            action = Action.from_json(request.body.read)
          else
            action = Action.from_xml(request.body.read)
          end
          network_port.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      action :stop, :with_capability => :stop_network_port do
        description "Stop specific NetworkPort."
        control do
          network_port = NetworkPort.find(params[:id], self)
          report_error(404) unless network_port
          if request.content_type.end_with?("json")
            action = Action.from_json(request.body.read)
          else
            action = Action.from_xml(request.body.read)
          end
          network_port.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

    end

  end
end
