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

require 'cimi/dependencies'
require 'cimi/helpers/cimi_helper'
require 'cimi/model'

set :version, '0.1.0'

include Deltacloud::Drivers
include CIMI::Model

set :drivers, Proc.new { driver_config }

Sinatra::Application.register Rack::RespondTo

use Rack::ETag
use Rack::Runtime
use Rack::MatrixParams
use Rack::DriverSelect
use Rack::MediaType
use Rack::Date
use Rack::CIMI

configure do
  set :root_url, "/cimi"
  set :views, File::join($top_srcdir, 'views', 'cimi')
  set :public_folder, File::join($top_srcdir, 'public')
  driver
end

configure :production do
  use Rack::SyslogLogger
  disable :logging
  enable :show_errors
  set :dump_errors, false
  $stdout = SyslogFile.new
  $stderr = $stdout
end

configure :development do
  set :raise_errors => false
  set :show_exceptions, false
  $stdout.sync = true
  $stderr.sync = true
end

# You could use $API_HOST environment variable to change your hostname to
# whatever you want (eg. if you running API behind NAT)
HOSTNAME=ENV['API_HOST'] ? ENV['API_HOST'] : nil

error do
  report_error
end

get "/" do
  redirect settings.root_url
end

get "#{settings.root_url}\/?" do
  halt 401 if params[:force_auth] and not driver.valid_credentials?(credentials)
  redirect cloudEntryPoint_url, 301
end

global_collection  :cloudEntryPoint do
  description 'Cloud entry point'
  operation :index do
    description "list all resources of the cloud"
    control do
      entry_point = CloudEntryPoint.create(self)
      respond_to do |format|
        format.xml { entry_point.to_xml }
        format.json { entry_point.to_json }
      end
    end
  end
end

global_collection :machine_configurations do
  description 'List all machine configurations'

  operation :index do
    param :CIMISelect,  :string,  :optional
    description "List all machine configurations"
    control do
      machine_configs = MachineConfigurationCollection.default(self).filter_by(params[:CIMISelect])
      respond_to do |format|
        format.xml { machine_configs.to_xml }
        format.json { machine_configs.to_json }
      end
    end
  end

  operation :show do

    description "The Machine Configuration entity represents the set of configuration values "+
      "that define the (virtual) hardware resources of a to-be-realized Machine Instance.."

    param :id, :string, :required

    control do
      machine_conf = MachineConfiguration.find(params[:id], self)
      respond_to do |format|
        format.xml { machine_conf.to_xml }
        format.json { machine_conf.to_json }
      end
    end

  end
end

global_collection :machine_images do
  description 'List all machine images'

  operation :index do
    description "List all machine configurations"
    param :CIMISelect,  :string,  :optional
    control do
      machine_images = MachineImageCollection.default(self).filter_by(params[:CIMISelect])
      respond_to do |format|
        format.xml { machine_images.to_xml }
        format.json { machine_images.to_json }
      end
    end
  end

  operation :show do
    description "Show specific machine image."
    param :id,          :string,    :required
    control do
      machine_image = MachineImage.find(params[:id], self)
      respond_to do |format|
        format.xml { machine_image.to_xml }
        format.json { machine_image.to_json }
      end
    end
  end

end

global_collection :machine_admins do
  description 'Machine Admin entity'

  operation :index do
    description "List all machine admins"
    param :CIMISelect,  :string,  :optional
    with_capability :keys
    control do
      machine_admins = MachineAdminCollection.default(self).filter_by(params[:CIMISelect])
      respond_to do |format|
        format.xml { machine_admins.to_xml }
        format.json { machine_admins.to_json }
      end
    end
  end

  operation :show do
    description "Show specific machine admin"
    param :id,          :string,    :required
    with_capability :key
    control do
      machine_admin = MachineAdmin.find(params[:id], self)
      respond_to do |format|
        format.xml { machine_admin.to_xml }
        format.json { machine_admin.to_json }
      end
    end
  end

  operation :create do
    description "Show specific machine admin"
    with_capability :create_key
    control do
      if request.content_type.end_with?("+json")
        new_admin = MachineAdmin.create_from_json(request.body.read, self)
      else
        new_admin = MachineAdmin.create_from_xml(request.body.read, self)
      end
      status 201 # Created
      respond_to do |format|
        format.json { new_admin.to_json }
        format.xml { new_admin.to_xml }
      end
    end
  end

  operation :delete, :method => :delete, :member => true do
    description "Delete specified MachineAdmin entity"
    param :id,          :string,    :required
    control do
      MachineAdmin.delete!(params[:id], self)
      no_content_with_status(200)
    end
  end

end

global_collection :machines do
  description 'List all machine'

  operation :index do
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

  operation :show do
    description "Show specific machine."
    param :id,          :string,    :required
    control do
      machine = Machine.find(params[:id], self)
      respond_to do |format|
        format.xml { machine.to_xml }
        format.json { machine.to_json }
      end
    end
  end

  operation :create do
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

  operation :destroy do
    description "Delete a specified machine."
    param :id,          :string,    :required
    control do
      Machine.delete!(params[:id], self)
      no_content_with_status(200)
    end
  end

  operation :stop, :method => :post, :member => true do
    description "Stop specific machine."
    param :id,          :string,    :required
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

  operation :restart, :method => :post, :member => true do
    description "Start specific machine."
    param :id,          :string,    :required
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

  operation :start, :method => :post, :member => true do
    description "Start specific machine."
    param :id,          :string,    :required
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
  operation :attach_volume, :method => :put, :member => true do
    description "Attach CIMI Volume(s) to a machine."
    param :id, :string, :required
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

  operation :detach_volume, :method => :put, :member => true do
    description "Detach CIMI Volume(s) from a machine."
    param :id, :string, :required
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

global_collection :volumes do
  description "Volume represents storage at either the block or file-system level. Volumes can be attached to Machines. Once attached, Volumes can be accessed by processes on that Machine"

  operation :index do
    description "List all volumes"
    param :CIMISelect,  :string,  :optional
    control do
      volumes = VolumeCollection.default(self).filter_by(params[:CIMISelect])
      respond_to do |format|
        format.xml { volumes.to_xml }
        format.json { volumes.to_json }
      end
    end
  end

  operation :show do
    description "Show specific Volume."
    param :id, :string, :required
    control do
      volume = Volume.find(params[:id], self)
      if volume
        respond_to do |format|
          format.xml  { volume.to_xml  }
          format.json { volume.to_json }
        end
      else
        report_error(404)
      end
    end
  end

  operation :create do
    description "Create a new Volume."
    control do
      content_type = (request.content_type.end_with?("+json") ? :json  : :xml)
          #((request.content_type.end_with?("+xml")) ? :xml : report_error(415) ) FIXME
      case content_type
        when :json
          new_volume = Volume.create_from_json(request.body.read, self)
        when :xml
          new_volume = Volume.create_from_xml(request.body.read, self)
      end
      respond_to do |format|
        format.json { new_volume.to_json }
        format.xml { new_volume.to_xml }
      end
    end
  end

  operation :destroy do
    description "Delete a specified Volume"
    param :id, :string, :required
    control do
      Volume.delete!(params[:id], self)
      no_content_with_status(200)
    end
  end

end

global_collection :volume_configurations do
  description "The Volume Configuration entity represents the set of configuration values needed to create a Volume with certain characteristics. Volume Configurations are created by Providers and MAY, at the Providers discretion, be created by Consumers"

  operation :index do
    description "Get list all VolumeConfigurations"
    param :CIMISelect,  :string,  :optional
    control do
      volume_configuration = VolumeConfigurationCollection.default(self).filter_by(params[:CIMISelect])
      respond_to do |format|
        format.xml { volume_configuration.to_xml }
        format.json { volume_configuration.to_json }
      end
    end
  end

  operation :show do
    description "Get a specific VolumeConfiguration"
    param :id, :required, :string
    control do
      volume_config = VolumeConfiguration.find(params[:id], self)
      respond_to do |format|
        format.xml { volume_config.to_xml }
        format.json { volume_config.json }
      end
    end
  end

global_collection :volume_images do
  description 'This entity represents an image that could be place on a pre-loaded volume.'

  operation :index do
    description "List all volumes images"
    param :CIMISelect,  :string,  :optional
    control do
      volume_images = VolumeImageCollection.default(self).filter_by(params[:CIMISelect])
      respond_to do |format|
        format.xml { volume_images.to_xml }
        format.json { volume_images.to_json }
      end
    end
  end

  operation :show do
    description "Show a specific volume image"
    param :id, :string, :required
    control do
      volume_image = VolumeImage.find(params[:id], self)
      respond_to do |format|
        format.xml { volume_image.to_xml }
        format.json { volume_image.to_json }
      end
    end
  end

end


global_collection :entity_metadata do
  description 'This allows for the discovery of Provider defined constraints on the CIMI defined attributes as well as discovery of any new extension attributes that the Provider may have defined.'

  operation :index do
    description "List all entity metadata defined for this provider"
    control do
      entity_metadata = EntityMetadataCollection.default(self)
      respond_to do |format|
        format.xml{entity_metadata.to_xml}
        format.json{entity_metadata.to_json}
      end
    end
  end

  operation :show do
    description "Get the entity metadata for a specific collection"
    param :id, :required, :string
    control do
      entity_metadata = EntityMetadata.find(params[:id], self)
      respond_to do |format|
        format.xml{entity_metadata.to_xml}
        format.json{entity_metadata.to_json}
      end
    end
  end

end

global_collection :networks do
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
    param :id, :string, :required
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

  operation :start, :method => :post, :member => true do
    description "Start specific network."
    param :id,          :string,    :required
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

  operation :stop, :method => :post, :member => true do
    description "Stop specific network."
    param :id,          :string,    :required
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

  operation :suspend, :method => :post, :member => true do
    description "Suspend specific network."
    param :id,          :string,    :required
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

global_collection :network_configurations do
  description 'Network Configurations contain the set of configuration values representing the information needed to create a Network with certain characteristics'

  operation :index do
    description 'List all NetworkConfigurations'
    param :CIMISelect, :string, :optional
    control do
      network_configurations = NetworkConfigurationCollection.default(self).filter_by(params[:CIMISelect])
      respond_to do |format|
        format.xml { network_configurations.to_xml  }
        format.json { network_configurations.to_json }
      end
    end
  end

  operation :show do
    description 'Show a specific NetworkConfiguration'
    param :id, :string, :required
    control do
      network_config = NetworkConfiguration.find(params[:id], self)
      respond_to do |format|
        format.xml { network_config.to_xml }
        format.json { network_config.to_json }
      end
    end
  end
end
end

global_collection :network_templates do

  description 'Network Template is a set of configuration values for realizing a Network. An instance of Network Template may be used to create multiple Networks'

  operation :index do
    description 'List all Network Templates in the NetworkTemplateCollection'
    param :CIMISelect, :string, :optional
    control do
      network_templates = NetworkTemplateCollection.default(self).filter_by(params[:CIMISelect])
      respond_to do |format|
        format.xml {network_templates.to_xml}
        format.json {network_templates.to_json}
      end
    end
  end

  operation :show do
    description 'Show a specific Network Template'
    param :id, :string, :required
    control do
      network_template = NetworkTemplate.find(params[:id], self)
      respond_to do |format|
        format.xml {network_template.to_xml}
        format.json {network_template.to_json}
      end
    end
  end

end


global_collection :routing_groups do

  description 'Routing Groups represent a collection of Networks that route to each other. Providers shall not allow two Networks to be routable to each other unless they are explicitly connected by being part of a common RoutingGroup.'

  operation :index do
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

  operation :show do
    description 'Show a specific RoutingGroup'
    param :id, :string, :required
    control do
      routing_group = RoutingGroup.find(params[:id], self)
      respond_to do |format|
        format.xml {routing_group.to_xml}
        format.json {routing_group.to_json}
      end
    end
  end

end


global_collection :routing_group_templates do

  description 'Routing Groups Templates capture the configuration values for realizing a RoutingGroup. A Routing Group Template may be used to create multiple RoutingGroups'

  operation :index do
    description 'List all RoutingGroupTemplates in the RoutingGroupTemplateCollection'
    param :CIMISelect, :string, :optional
    control do
      routing_group_templates = RoutingGroupTemplateCollection.default(self).filter_by(params[:CIMISelect])
      respond_to do |format|
        format.xml {routing_group_templates.to_xml}
        format.json {routing_group_templates.to_json}
      end
    end
  end

  operation :show do
    description 'Show a specific RoutingGroupTemplate'
    param :id, :string, :required
    control do
      routing_group_template = RoutingGroupTemplate.find(params[:id], self)
      respond_to do |format|
        format.xml {routing_group_template.to_xml}
        format.json {routing_group_template.to_json}
      end
    end
  end

end


global_collection :vsps do

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
    param :id, :string, :required
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
    param :id, :string, :required
    control do
      CIMI::Model::VSP.delete!(params[:id], self)
      no_content_with_status(200)
    end
  end

  operation :start, :method => :post, :member => true do
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

  operation :stop, :method => :post, :member => true do
    description "Stop specific VSP."
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

end

global_collection :vsp_configurations do

  description 'A VSP Configuration is the set of configuration values representing the information needed to create a VSP with certain characteristics'

  operation :index do
    description 'List all VSPConfigurations in the VSPConfigurationCollection'
    param :CIMISelect, :string, :optional
    control do
      vsp_configs = VSPConfigurationCollection.default(self).filter_by(params[:CIMISelect])
      respond_to do |format|
        format.xml {vsp_configs.to_xml}
        format.json {vsp_configs.to_json}
      end
    end
  end

  operation :show do
    description 'Show a specific VSPConfiguration'
    param :id, :string, :required
    control do
      vsp_config = VSPConfiguration.find(params[:id], self)
      respond_to do |format|
        format.xml {vsp_config.to_xml}
        format.json {vsp_config.to_json}
      end
    end
  end

end


global_collection :vsp_templates do

  description 'The VSP Template is a set of Configuration values for realizing a VSP. A VSP Template may be used to create multiple VSPs'

  operation :index do
    description 'List all VSPTemplates in the VSPTemplateCollection'
    param :CIMISelect, :string, :optional
    control do
      vsp_templates = VSPTemplateCollection.default(self).filter_by(params[:CIMISelect])
      respond_to do |format|
        format.xml {vsp_templates.to_xml}
        format.json {vsp_templates.to_json}
      end
    end
  end

  operation :show do
    description 'Show a specific VSPTemplate'
    param :id, :string, :required
    control do
      vsp_template = VSPTemplate.find(params[:id], self)
      respond_to do |format|
        format.xml {vsp_template.to_xml}
        format.json {vsp_template.to_json}
      end
    end
  end

end

global_collection :addresses do

  description 'An Address represents an IP address, and its associated metdata, for a particular Network.'

  operation :index do
    description 'List all Addresses in the AddressCollection'
    param :CIMISelect, :string, :optional
    control do
      addresses = AddressCollection.default(self).filter_by(params[:CIMISelect])
      respond_to do |format|
        format.xml {addresses.to_xml}
        format.json {addresses.to_json}
      end
    end
  end

  operation :show do
    description 'Show a specific Address'
    param :id, :string, :required
    control do
      address = CIMI::Model::Address.find(params[:id], self)
      respond_to do |format|
        format.xml {address.to_xml}
        format.json {address.to_json}
      end
    end
  end

  operation :create do
    description "Create a new Address"
    control do
      if request.content_type.end_with?("json")
        address = CIMI::Model::Address.create(request.body.read, self, :json)
      else
        address = CIMI::Model::Address.create(request.body.read, self, :xml)
      end
      respond_to do |format|
        format.xml { address.to_xml }
        format.json { address.to_json }
      end
    end
  end

  operation :destroy do
    description "Delete a specified Address"
    param :id, :string, :required
    control do
      CIMI::Model::Address.delete!(params[:id], self)
      no_content_with_status(200)
    end
  end

end


global_collection :address_templates do

  description 'An AddressTemplate captures the configuration values for realizing an Address. An Address Template may be used to create multiple Addresses.'

  operation :index do
    description 'List all AddressTemplates in the AddressTemplateCollection'
    param :CIMISelect, :string, :optional
    control do
      address_templates = AddressTemplateCollection.default(self).filter_by(params[:CIMISelect])
      respond_to do |format|
        format.xml {address_templates.to_xml}
        format.json {address_templates.to_json}
      end
    end
  end

  operation :show do
    description 'Show a specific AddressTemplate'
    param :id, :string, :required
    control do
      address_template = CIMI::Model::AddressTemplate.find(params[:id], self)
      respond_to do |format|
        format.xml {address_template.to_xml}
        format.json {address_template.to_json}
      end
    end
  end

end
