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
      machines = Machine.all(self)
      respond_to do |format|
        format.xml { machines.to_xml_cimi_collection(self) }
        format.json { machines.to_json_cimi_collection(self) }
      end
    end
  end

  operation :show do
    description "Show specific machine."
    with_capability :instance
    param :id,          :string,    :required
    control do
      machine = Machine.find(params[:id], self)
      respond_to do |format|
        format.xml { machine.to_xml }
        format.json { machine.to_json }
      end
    end
  end

  operation :delete, :method => :post, :member => true do
    description "Reboot specific machine."
    param :id,          :string,    :required
    control do
      machine = Machine.find(params[:id], self)
      machine.perform :destroy do |operation|
        operation.body = request.body.read
        operation.content_type = params[:content_type]
        operation.on :success do
          # We *should* return 202 - Accepted because the 'reboot' operation will not be processed
          # immediately
          no_content_with_status 202
        end
        operation.on :failure do
          # error...
        end
      end
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

end

global_collection :volumes do
  description "Volume represents storage at either the block or file-system level. Volumes can be attached to Machines. Once attached, Volumes can be accessed by processes on that Machine"

  operation :index do
    description "List all volumes"
    control do
      volumes = Volume.all(self)
      respond_to do |format|
        format.xml { volumes.to_xml_cimi_collection(self) }
        format.json { volumes.to_json_cimi_collection(self) }
      end
    end
  end

  operation :show do
    description "Show specific Volume."
    param :id, :string, :required
    control do
      volume = Volume.find(params[:id], self)
      respond_to do |format|
        format.xml  { volume.to_xml  }
        format.json { volume.to_json }
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
          json = JSON.parse(request.body.read)
          volume_config_id = json["volumeTemplate"]["volumeConfig"]["href"].split("/").last
          volume_image_id = (json["volumeTemplate"].has_key?("volumeImage") ?
                      json["volumeTemplate"]["volumeImage"]["href"].split("/").last  : nil)
        when :xml
          xml = XmlSimple.xml_in(request.body.read)
          volume_config_id = xml["volumeTemplate"][0]["volumeConfig"][0]["href"].split("/").last
          volume_image_id = (xml["volumeTemplate"][0].has_key?("volumeImage") ?
                      xml["volumeTemplate"][0]["volumeImage"][0]["href"].split("/").last  : nil)
      end
      params.merge!( {:volume_config_id => volume_config_id, :volume_image_id => volume_image_id} )
      new_volume = Volume.create(params, self)
      respond_to do |format|
        format.json { new_volume.to_json }
        format.xml { new_volume.to_xml }
      end
    end
  end




end

global_collection :volume_configurations do
  description "The Volume Configuration entity represents the set of configuration values needed to create a Volume with certain characteristics. Volume Configurations are created by Providers and MAY, at the Providers discretion, be created by Consumers"

  operation :index do
    description "Get list all VolumeConfigurations"
    control do
      volume_configs = VolumeConfiguration.all(self)
      respond_to do |format|
        format.xml { volume_configs.to_xml_cimi_collection(self) }
        format.json { volume_configs.to_json_cimi_collection(self) }
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
    control do
      volume_images = VolumeImage.all(self)
      respond_to do |format|
        format.xml { volume_images.to_xml_cimi_collection(self) }
        format.json { volume_images.to_json_cimi_collection(self) }
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

end
