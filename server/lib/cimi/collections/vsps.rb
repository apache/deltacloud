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
  class Vsps < Base

    check_capability :for => lambda { |m| driver.respond_to? m }
    collection :vsps do

      description 'A VSP represents the connection parameters of a network port'

      operation :index do
        description 'List all VSPs in the VSPCollection'
        param :CIMISelect, :string, :optional
        control do
          vsps = VSPCollection.default(self).filter_by(params[:CIMISelect])
          respond_to do |format|
            format.xml {vsps.to_xml}
            format.json {vsps.to_json}
          end
        end
      end

      operation :show do
        description 'Show a specific VSP'
        control do
          vsp = VSP.find(params[:id], self)
          respond_to do |format|
            format.xml {vsp.to_xml}
            format.json {vsp.to_json}
          end
        end
      end

      operation :create do
        description "Create a new VSP"
        control do
          if request.content_type.end_with?("json")
            vsp = CIMI::Model::VSP.create(request.body.read, self, :json)
          else
            vsp = CIMI::Model::VSP.create(request.body.read, self, :xml)
          end
          respond_to do |format|
            format.xml { vsp.to_xml }
            format.json { vsp.to_json }
          end
        end
      end

      operation :destroy do
        description "Delete a specified VSP"
        control do
          CIMI::Model::VSP.delete!(params[:id], self)
          no_content_with_status(200)
        end
      end

      action :start do
        description "Start specific VSP."
        param :id,          :string,    :required
        control do
          vsp = VSP.find(params[:id], self)
          report_error(404) unless vsp
          if request.content_type.end_with?("json")
            action = Action.from_json(request.body.read)
          else
            action = Action.from_xml(request.body.read)
          end
          vsp.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      action :stop do
        description "Stop specific VSP."
        control do
          vsp = VSP.find(params[:id], self)
          report_error(404) unless vsp
          if request.content_type.end_with?("json")
            action = Action.from_json(request.body.read)
          else
            action = Action.from_xml(request.body.read)
          end
          vsp.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

    end

  end
end
