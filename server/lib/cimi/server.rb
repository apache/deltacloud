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


require 'cimi/helpers/dmtfdep'
require 'cimi/helpers/cmwgapp_helper'
require 'cimi/helpers/cimi_helper'
require 'deltacloud/core_ext'
require 'cimi/model'

set :version, '0.1.0'

include Deltacloud::Drivers
include CIMI::Model
set :drivers, Proc.new { driver_config }

STOREROOT = File.join($top_srcdir, 'lib', 'cimi', 'data')
Sinatra::Application.register Rack::RespondTo

use Rack::ETag
use Rack::Runtime
use Rack::MatrixParams
use Rack::DriverSelect
use Rack::MediaType
use Rack::Date

configure do
  set :root_url, "/cimi"
  set :views, File::join($top_srcdir, 'views', 'cimi')
  # NOTE: Change :public to :public_folder once we update sinatra to 1.3
  # set :public_folder, File::join($top_srcdir, 'public')
  set :public_folder, File::join($top_srcdir, 'public')
  # Try to load the driver on startup to fail early if there are issues
  driver
  set :store, STOREROOT
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
  redirect "#{settings.root_url}/cloudEntryPoint", 301
end

global_collection  :cloudEntryPoint do
  description 'Cloud entry point'

  operation :index do
    description "list all resources of the cloud"
    control do
      @collections = entry_points.reject { |p| p[0] == :cloudEntryPoint }
      show_resource "cloudEntryPoint/index", "CloudEntryPoint"
    end
  end
end

global_collection :machine_configurations do
  description 'List all machine configurations'

  operation :index do
    description "List all machine configurations"
    control do
      machine_configs = MachineConfiguration.all(self)
      respond_to do |format|
        format.xml { machine_configs.to_xml_cimi_collection(self) }
        format.json { machine_configs.to_json_cimi_collection(self) }
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
    control do
      machine_images = MachineImage.all(self)
      respond_to do |format|
        format.xml { machine_images.to_xml_cimi_collection(self) }
        format.json { machine_images.to_json_cimi_collection(self) }
      end
    end
  end

  operation :show do
    description "Show specific machine image."
    with_capability :image
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

global_collection :machines do
  description 'List all machine'

  operation :index do
    description "List all machines"
    control do
      instances = driver.send(:instances, credentials, {})
      @dmtf_col_items = []
      if instances
        instances.map do |instance|
          new_item = { "name" => instance.name,
            "href" => machine_url(instance.id) }
          @dmtf_col_items.insert 0,  new_item
        end
      end
      respond_to_collection "machine.col.xml"
    end
  end

  operation :show do
    description "Show specific machine."
    with_capability :instance
    param :id,          :string,    :required
    control do
      @machine = driver.send(:instance, credentials, { :id => params[:id]} )
      if @machine
        #setup the default values for a machine imageion
        resource_default = get_resource_default "machine"
        #get the actual values from image
        resource_value = { "name" => @machine.name,
          "status" => @machine.state, "uri" => @machine.id,
          "href" => machine_url(@machine.id) }
        #mixin actual values get from the specific image
        @dmtfitem = resource_default["dmtfitem"].merge resource_value
        show_resource "machines/show", "Machine",
          {"property" => "properties", "disk" => "disks", "operation" => "operations"}
      else
        report_error(404)
      end
    end
  end

end

global_collection :volumes do
  description 'List all volumes'

  operation :index do
    description "List all volumes"
    control do
      instances = driver.send(:storage_volumes, credentials, {})
      @dmtf_col_items = []
      if instances
        instances.map do |instance|
          new_item = { "name" => instance.id,
            "href" => volume_url(instance.id) }
          @dmtf_col_items.insert 0,  new_item
        end
      end
      respond_to_collection "volume.col.xml"
    end
  end

  operation :show do
    description "Show specific machine."
    with_capability :storage_volume
    param :id,          :string,    :required
    control do
      @volume = driver.send(:storage_volume, credentials, { :id => params[:id]} )
      if @volume
        #setup the default values for a machine imageion
        resource_default = get_resource_default "volume"
        #get the actual values from image
        resource_value = { "name" => @volume.id,
          "status" => @volume.state, "uri" => @volume.id,
          "href" => volume_url(@volume.id),
          "capacity" => { "quantity" => @volume.capacity, "units" => "gigabyte"} }
        #mixin actual values get from the specific image
        @dmtfitem = resource_default["dmtfitem"].merge resource_value
        show_resource "volumes/show", "Volume",
          {"property" => "properties", "operation" => "operations"}
      else
        report_error(404)
      end
    end
  end

end
