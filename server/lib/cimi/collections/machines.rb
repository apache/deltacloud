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
  class Machines < Base

    set :capability, lambda { |m| driver.respond_to? m }

    collection :machines do
      description 'List all machine'

      operation :index, :with_capability => :instances do
        param :CIMISelect,  :string,  :optional
        description "List all machines"
        control do
          machines = MachineCollection.default(self).filter_by(params[:CIMISelect])
          respond_to do |format|
            format.xml { machines.to_xml }
            format.json { machines.to_json }
          end
        end
      end

      operation :show, :with_capability => :instance do
        description "Show specific machine."
        control do
          machine = Machine.find(params[:id], self)
          respond_to do |format|
            format.xml { machine.to_xml }
            format.json { machine.to_json }
          end
        end
      end

      operation :create, :with_capability => :create_instance do
        description "Create a new Machine entity."
        control do
          if request.content_type.end_with?("+json")
            new_machine = Machine.create_from_json(request.body.read, self)
          else
            new_machine = Machine.create_from_xml(request.body.read, self)
          end
          status 201 # Created
          respond_to do |format|
            format.json { new_machine.to_json }
            format.xml { new_machine.to_xml }
          end
        end
      end

      operation :destroy, :with_capability => :destroy_instance do
        description "Delete a specified machine."
        param :id,          :string,    :required
        control do
          Machine.delete!(params[:id], self)
          no_content_with_status(200)
        end
      end

      action :stop, :with_capability => :stop_instance do
        description "Stop specific machine."
        control do
          machine = Machine.find(params[:id], self)
          if request.content_type.end_with?("+json")
            action = Action.from_json(request.body.read)
          else
            action = Action.from_xml(request.body.read)
          end
          machine.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      action :restart, :with_capability => :restart_instance do
        description "Start specific machine."
        control do
          machine = Machine.find(params[:id], self)
          if request.content_type.end_with?("+json")
            action = Action.from_json(request.body.read)
          else
            action = Action.from_xml(request.body.read)
          end
          machine.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      action :start, :with_capability => :start_instance do
        description "Start specific machine."
        control do
          machine = Machine.find(params[:id], self)
          if request.content_type.end_with?("+json")
            action = Action.from_json(request.body.read)
          else
            action = Action.from_xml(request.body.read)
          end
          machine.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      #NOTE: The routes for attach/detach used here are NOT as specified by CIMI
      #will likely move later. CIMI specifies PUT of the whole Machine description
      #with inclusion/ommission of the volumes you want [att|det]ached
      action :attach_volume, :http_method => :put, :with_capability => :attach_storage_volume do
        description "Attach CIMI Volume(s) to a machine."
        control do
          if request.content_type.end_with?("+json")
            volumes_to_attach = Volume.find_to_attach_from_json(request.body.read, self)
          else
            volumes_to_attach = Volume.find_to_attach_from_xml(request.body.read, self)
          end
          machine = Machine.attach_volumes(volumes_to_attach, self)
          respond_to do |format|
            format.json{ machine.to_json}
            format.xml{machine.to_xml}
          end
        end
      end

      action :detach_volume, :http_method => :put, :with_capability => :detach_storage_volume do
        description "Detach CIMI Volume(s) from a machine."
        control do
          if request.content_type.end_with?("+json")
            volumes_to_detach = Volume.find_to_attach_from_json(request.body.read, self)
          else
            volumes_to_detach = Volume.find_to_attach_from_xml(request.body.read, self)
          end
          machine = Machine.detach_volumes(volumes_to_detach, self)
          respond_to do |format|
            format.json{ machine.to_json}
            format.xml{machine.to_xml}
          end
        end
      end
    end

  end
end
