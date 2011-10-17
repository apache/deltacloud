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

set :version, '0.1.0'

include Deltacloud::Drivers
set :drivers, Proc.new { driver_config }

STOREROOT = File.join($top_srcdir, 'lib', 'cimi', 'data')
#We would like to know the storage root.
puts "store root is " + STOREROOT

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
  set :public, File::join($top_srcdir, 'public')
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

get "#{settings.root_url}\/?" do
  if params[:force_auth]
    return [401, 'Authentication failed'] unless driver.valid_credentials?(credentials)
  end

  redirect "#{settings.root_url}/cloudEntryPoint", 301
end

collection  :cloudEntryPoint do
  # Make sure this collection can be accessed, regardless of whether the
  # driver supports it or not
  global!

  description <<EOS
  cloud entry point
EOS

  operation :index do
    description "list all resources of the cloud"
    control do
      @collections = entry_points.reject { |p| p[0] == :cloudEntryPoint }
      show_resource "cloudEntryPoint/index", "CloudEntryPoint"
    end
  end
end

collection :machine_configurations do
  global!

  description <<EOS
List all machine configurations
EOS

  operation :index do
    description "List all machine configurations"
    control do
      profiles = driver.hardware_profiles(credentials, nil)
      @dmtf_col_items = []
      if profiles
        profiles.map do |profile|
          new_item = { "name" => profile.name,
            "href" => machine_configuration_url(profile.name) }
          @dmtf_col_items.insert 0,  new_item
        end
      end
      respond_to_collection "machine_configuration.col.xml"
    end
  end

  operation :show do
    description "Show specific machine configuration."
    with_capability :hardware_profile
    param :id,          :string,    :required
    control do
      @profile =  driver.hardware_profile(credentials, params[:id])
      if @profile
        #setup the default values for a machine configuration
        resource_default = get_resource_default "machine_configuration"
        #get the actual values from profile
        resource_value = { "name" => @profile.name,"uri" => @profile.name,
              "href" => machine_configuration_url(@profile.name) }
        #mixin actual values get from profile
        @dmtfitem = resource_default["dmtfitem"].merge resource_value
        show_resource "machine_configurations/show", "MachineConfiguration"
      else
        report_error(404)
      end
    end
  end
end

collection :machine_images do
  global!

  description <<EOS
List all machine images
EOS

  operation :index do
    description "List all machine configurations"
    control do
      images = driver.send(:images, credentials, {})
      @dmtf_col_items = []
      if images
        images.map do |image|
          new_item = { "name" => image.name,
            "href" => machine_image_url(image.id) }
          @dmtf_col_items.insert 0,  new_item
        end
      end
      respond_to_collection "machine_image.col.xml"
    end
  end

  operation :show do
    description "Show specific machine image."
    with_capability :image
    param :id,          :string,    :required
    control do
      @image = driver.send(:image, credentials, { :id => params[:id]} )
      if @image
        #setup the default values for a machine imageion
        resource_default = get_resource_default "machine_image"
        #get the actual values from image
        resource_value = { "name" => @image.name,
          "description" => @image.description,
          "uri" => @image.id,"href" => machine_image_url(@image.id) }
        #mixin actual values get from the specific image
        @dmtfitem = resource_default["dmtfitem"].merge resource_value
        show_resource "machine_images/show", "MachineImage"
      else
        report_error(404)
      end
    end
  end

end

collection :machines do
  global!

  description <<EOS
List all machine
EOS

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
        show_resource "machines/show", "Machine"
      else
        report_error(404)
      end
    end
  end

end

collection :volumes do
  global!

  description <<EOS
List all volumes
EOS

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
        show_resource "volumes/show", "Volume"
      else
        report_error(404)
      end
    end
  end

end
