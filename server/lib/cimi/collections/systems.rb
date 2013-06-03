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

    post '/systems/import' do
      CIMI::Service::SystemImport.parse(self).import
      no_content_with_status(202)
    end

    collection :systems do
      description 'List all systems'

      generate_index_operation :with_capability => :systems
      generate_show_operation :with_capability => :systems
      generate_create_operation :with_capability => :create_system
      generate_delete_operation :with_capability => :destroy_system

      action :stop, :with_capability => :stop_system do
        description "Stop specific system."
        param :id,          :string,    :required
        control do
          system = System.find(params[:id], self)
          action = Action.parse(self)
          system.perform(action) do |operation|
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
          action = Action.parse(self)
          system.perform(action) do |operation|
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
          action = Action.parse(self)
          system.perform(action) do |operation|
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
          action = Action.parse(self)
          system.perform(action) do |operation|
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
          action = Action.parse(self)
          system.perform(action) do |operation|
            no_content_with_status(202) if operation.success?
            # Handle errors using operation.failure?
          end
        end
      end

      action :export, :with_capability => :export_system do
        description "Export specific system."
        param :id,          :string,    :required
        control do
          location = CIMI::Service::SystemExport.parse(self).export(params[:id])
          if location
            header_for_location(location)
          else
            no_content_with_status(202)
            # Handle errors using operation.failure?
          end
        end
      end

      collection :systems, :with_id => :ent_id do
        description 'List system\'s systems'
        generate_system_subcollection_index_operation :with_capability => :system_systems
        generate_system_subcollection_show_operation :with_capability => :system_systems
        generate_add_to_system_operation :with_capability => :create_system_system
        generate_remove_from_system_operation :with_capability => :destroy_system_system
      end

      collection :machines, :with_id => :ent_id do
        description 'List system\'s machines'
        generate_system_subcollection_index_operation :with_capability => :system_machines
        generate_system_subcollection_show_operation :with_capability => :system_machines
        generate_add_to_system_operation :with_capability => :create_system_machine
        generate_remove_from_system_operation :with_capability => :destroy_system_machine
      end

      collection :credentials, :with_id => :ent_id do
        description 'List system\'s credentials'
        generate_system_subcollection_index_operation :with_capability => :system_credentials
        generate_system_subcollection_show_operation :with_capability => :system_credentials
        generate_add_to_system_operation :with_capability => :create_system_credential
        generate_remove_from_system_operation :with_capability => :destroy_system_credential
      end

      collection :volumes, :with_id => :ent_id do
        description 'List system\'s volumes'
        generate_system_subcollection_index_operation :with_capability => :system_volumes
        generate_system_subcollection_show_operation :with_capability => :system_volumes
        generate_add_to_system_operation :with_capability => :create_system_volume
        generate_remove_from_system_operation :with_capability => :destroy_system_volume
      end

      collection :networks, :with_id => :ent_id do
        description 'List system\'s networks'
        generate_system_subcollection_index_operation :with_capability => :system_networks
        generate_system_subcollection_show_operation :with_capability => :system_networks
        generate_add_to_system_operation :with_capability => :create_system_network
        generate_remove_from_system_operation :with_capability => :destroy_system_network
      end

      collection :network_ports, :with_id => :ent_id do
        description 'List system\'s network ports'
        generate_system_subcollection_index_operation :with_capability => :system_network_ports
        generate_system_subcollection_show_operation :with_capability => :system_network_ports
        generate_add_to_system_operation :with_capability => :create_system_network_port
        generate_remove_from_system_operation :with_capability => :destroy_system_network_port
      end

      collection :addresses, :with_id => :ent_id do
        description 'List system\'s addresses'
        generate_system_subcollection_index_operation :with_capability => :system_addresses
        generate_system_subcollection_show_operation :with_capability => :system_addresses
        generate_add_to_system_operation :with_capability => :create_system_addresses
        generate_remove_from_system_operation :with_capability => :destroy_system_addresses
      end

      collection :forwarding_groups, :with_id => :ent_id do
        description 'List system\'s forwarding groups'
        generate_system_subcollection_index_operation :with_capability => :system_forwarding_groups
        generate_system_subcollection_show_operation :with_capability => :system_forwarding_groups
        generate_add_to_system_operation :with_capability => :create_system_forwarding_groups
        generate_remove_from_system_operation :with_capability => :destroy_system_forwarding_groups
      end

    end

  end
end
