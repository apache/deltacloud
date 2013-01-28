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
        description "List all machines"
        control do
          machines = Machine.list(self).select_by(params['$select'])
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
          if grab_content_type(request.content_type, request.body) == :json
            new_machine = Machine.create_from_json(request.body.read, self)
          else
            new_machine = Machine.create_from_xml(request.body.read, self)
          end
          headers_for_create new_machine
          respond_to do |format|
            format.json { new_machine.to_json }
            format.xml { new_machine.to_xml }
          end
        end
      end

      operation :destroy, :with_capability => :destroy_instance do
        description "Delete a specified machine."
        control do
          Machine.delete!(params[:id], self)
          no_content_with_status(200)
        end
      end

      action :stop, :with_capability => :stop_instance do
        description "Stop specific machine."
        param :id,          :string,    :required
        control do
          machine = Machine.find(params[:id], self)
          if grab_content_type(request.content_type, request.body) == :json
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

      action :restart, :with_capability => :reboot_instance do
        description "Start specific machine."
        param :id,          :string,    :required
        control do
          machine = Machine.find(params[:id], self)
          if  grab_content_type(request.content_type, request.body) == :json
            action = Action.from_json(request.body.read.gsub("restart", "reboot"))
          else
            action = Action.from_xml(request.body.read.gsub("restart", "reboot"))
          end
          machine.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      action :start, :with_capability => :start_instance do
        description "Start specific machine."
        param :id,          :string,    :required
        control do
          machine = Machine.find(params[:id], self)
          if  grab_content_type(request.content_type, request.body) == :json
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

      operation :disks, :with_capability => :hardware_profiles do
        description "Retrieve the Machine's DiskCollection"
        param :id,          :string,    :required
        control do
          disks = CIMI::Model::Disk.collection_for_instance(params[:id], self)
          respond_to do |format|
            format.json {disks.to_json}
            format.xml  {disks.to_xml}
          end
        end
      end

      #use rabbit subcollections for volumes index/show:
      collection :volumes, :with_id => :vol_id do

        operation :index, :with_capability => :storage_volumes do
          description "Retrieve the Machine's MachineVolumeCollection"
          control do
            volumes = CIMI::Model::MachineVolume.collection_for_instance(params[:id], self)
            respond_to do |format|
              format.json {volumes.to_json}
              format.xml  {volumes.to_xml}
            end
          end
        end

        operation :show, :with_capability => :storage_volumes do
          description "Retrieve a Machine's specific MachineVolume"
          control do
            volume = CIMI::Model::MachineVolume.find(params[:id], self, params[:vol_id])
            respond_to do |format|
              format.json {volume.to_json}
              format.xml  {volume.to_xml}
            end
          end
        end

        operation :destroy, :with_capability => :detach_storage_volume do
          description "Remove/detach a volume from the Machine's MachineVolumeCollection"
          control do
            machine_volume = CIMI::Model::MachineVolume.find(params[:id], self, params[:vol_id])
            location = machine_volume.initial_location
            machine_volumes = Machine.detach_volume(params[:vol_id], location, self)
            respond_to do |format|
              format.json{ machine_volumes.to_json}
              format.xml{ machine_volumes.to_xml}
            end
          end
        end

      end

      operation :volume_attach, :http_method => :post, :with_capability => :attach_storage_volume do
        description "Attach CIMI Volume(s) to a machine."
        param :id,          :string,    :required
        control do
          if  grab_content_type(request.content_type, request.body) == :json
            volume_to_attach, location = MachineVolume.find_to_attach_from_json(request.body.read, self)
          else
            volume_to_attach, location = MachineVolume.find_to_attach_from_xml(request.body.read, self)
          end
          machine_volume = Machine.attach_volume(volume_to_attach,location, self)
          headers_for_create machine_volume
          respond_to do |format|
            format.json{ machine_volume.to_json}
            format.xml{machine_volume.to_xml}
          end
        end
      end

    end

  end
end
