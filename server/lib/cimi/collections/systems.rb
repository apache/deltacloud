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
  class Systems < Base

    set :capability, lambda { |m| driver.respond_to? m }

    collection :systems do
      description 'List all systems'

      operation :index, :with_capability => :systems do
        description "List all systems"
        control do
          systems = System.list(self).select_by(params['$select']).filter_by(params['$filter'])
          respond_to do |format|
            format.xml { systems.to_xml }
            format.json { systems.to_json }
          end
        end
      end

      operation :show, :with_capability => :systems do
        description "Show specific system."
        control do
          system = System.find(params[:id], self)
          respond_to do |format|
            format.xml { system.to_xml }
            format.json { system.to_json }
          end
        end
      end

      operation :create, :with_capability => :create_system do
        description "Create a new System entity."
        control do
          if grab_content_type(request.content_type, request.body) == :json
            new_system = System.create_from_json(request.body.read, self)
          else
            new_system = System.create_from_xml(request.body.read, self)
          end
          headers_for_create new_system
          respond_to do |format|
            format.json { new_system.to_json }
            format.xml { new_system.to_xml }
          end
        end
      end

      operation :destroy, :with_capability => :destroy_system do
        description "Delete a specified system."
        control do
          System.delete!(params[:id], self)
          no_content_with_status(200)
        end
      end

      action :stop, :with_capability => :stop_system do
        description "Stop specific system."
        param :id,          :string,    :required
        control do
          system = System.find(params[:id], self)
          action = Action.parse(request.body,
          request.content_type)
          system.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      action :restart, :with_capability => :reboot_system do
        description "Restart specific system."
        param :id,          :string,    :required
        control do
          system = System.find(params[:id], self)
          if  grab_content_type(request.content_type, request.body) == :json
            action = Action.from_json(request.body.read.gsub("restart", "reboot"))
          else
            action = Action.from_xml(request.body.read.gsub("restart", "reboot"))
          end
          system.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      action :start, :with_capability => :start_system do
        description "Start specific system."
        param :id,          :string,    :required
        control do
          system = System.find(params[:id], self)
          if  grab_content_type(request.content_type, request.body) == :json
            action = Action.from_json(request.body.read)
          else
            action = Action.from_xml(request.body.read)
          end
          system.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      action :pause, :with_capability => :pause_system do
        description "Pause specific system."
        param :id,          :string,    :required
        control do
          system = System.find(params[:id], self)
          if  grab_content_type(request.content_type, request.body) == :json
            action = Action.from_json(request.body.read)
          else
            action = Action.from_xml(request.body.read)
          end
          system.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      action :suspend, :with_capability => :suspend_system do
        description "Suspend specific system."
        param :id,          :string,    :required
        control do
          system = System.find(params[:id], self)
          if  grab_content_type(request.content_type, request.body) == :json
            action = Action.from_json(request.body.read)
          else
            action = Action.from_xml(request.body.read)
          end
          system.perform(action, self) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      #use rabbit subcollections for volumes index/show:
      collection :volumes, :with_id => :vol_id do

        operation :index, :with_capability => :storage_volumes do
          description "Retrieve the System's SystemVolumeCollection"
          control do
            volumes = CIMI::Model::SystemVolume.collection_for_system(params[:id], self)
            respond_to do |format|
              format.json {volumes.to_json}
              format.xml  {volumes.to_xml}
            end
          end
        end

        operation :show, :with_capability => :storage_volumes do
          description "Retrieve a System's specific SystemVolume"
          control do
            volume = CIMI::Model::SystemVolume.find(params[:id], self, params[:vol_id])
            respond_to do |format|
              format.json {volume.to_json}
              format.xml  {volume.to_xml}
            end
          end
        end

        operation :destroy, :with_capability => :detach_storage_volume do
          description "Remove/detach a volume from the System's SystemVolumeCollection"
          control do
            system_volume = CIMI::Model::SystemVolume.find(params[:id], self, params[:vol_id])
            location = system_volume.initial_location
            system_volumes = System.detach_volume(params[:vol_id], location, self)
            respond_to do |format|
              format.json{ system_volumes.to_json}
              format.xml{ system_volumes.to_xml}
            end
          end
        end

      end
    end

  end
end
