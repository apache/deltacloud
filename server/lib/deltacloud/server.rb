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

require 'sinatra'
require 'deltacloud'
require 'json'
require 'sinatra/rack_accept'
require 'sinatra/static_assets'
require 'sinatra/rabbit'
require 'sinatra/lazy_auth'
require 'erb'
require 'haml'
require 'open3'
require 'sinatra/sinatra_verbose'
require 'sinatra/rack_driver_select'
require 'sinatra/rack_runtime'
require 'sinatra/rack_etag'
require 'sinatra/rack_date'
require 'sinatra/rack_matrix_params'
require 'sinatra/rack_syslog'

set :version, '0.4.1'

include Deltacloud::Drivers
set :drivers, Proc.new { driver_config }

Sinatra::Application.register Rack::RespondTo

use Rack::ETag
use Rack::Runtime
use Rack::MatrixParams
use Rack::DriverSelect
use Rack::MediaType
use Rack::Date

configure do
  set :root_url, "/api"
  set :views, File::join($top_srcdir, 'views')
  # NOTE: Change :public to :public_folder once we update sinatra to 1.3
  # set :public_folder, File::join($top_srcdir, 'public')
  if settings.respond_to? :public_folder
    set :public_folder, File::join($top_srcdir, 'public')
  else
    set :public, File::join($top_srcdir, 'public')
  end
  # Try to load the driver on startup to fail early if there are issues
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
  # So we can just use puts for logging
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

before do
  # Respond with 400, If we don't get a http Host header,
  halt 400, "Unable to find HTTP Host header" if @env['HTTP_HOST'] == nil
end

after do
  headers 'Server' => 'Apache-Deltacloud/' + settings.version
end

# Redirect to /api
get '/' do redirect settings.root_url, 301; end


# Generate a root route for API docs
get "#{settings.root_url}/docs\/?" do
  respond_to do |format|
    format.html { haml :'docs/index' }
    format.xml { haml :'docs/index' }
  end
end

get "#{settings.root_url}\/?" do
  if params[:force_auth]
    return [401, 'Authentication failed'] unless driver.valid_credentials?(credentials)
  end
  @collections = [:drivers] + driver.supported_collections
  @providers = driver.configured_providers
  respond_to do |format|
    format.xml { haml :"api/show" }
    format.json do
      { :api => {
          :version => settings.version,
          :driver => driver_symbol,
          :links => entry_points.collect do |l|
            { :rel => l[0], :href => l[1] }.merge(json_features_for_entrypoint(l))
          end
        }
      }.to_json
    end
    format.html { haml :"api/show" }
  end
end

post "#{settings.root_url}\/?"  do
  provider = params["provider"]
  if provider && provider != "default"
    redirect "#{settings.root_url}\;provider=#{params['provider']}", 301
  else
    redirect settings.root_url, 301
  end
end

# Rabbit DSL

collection :drivers do
  global!

  description <<EOS
List all the drivers supported by this server.
EOS

  operation :index do
    description "List all drivers"
    control do
      @drivers = settings.drivers
      respond_to do |format|
        format.xml { haml :"drivers/index" }
        format.json { @drivers.to_json }
        format.html { haml :"drivers/index" }
      end
    end
  end

  operation :show do
    description "Show details for a driver"
    param :id,      :string
    control do
      @name = params[:id].to_sym
      @providers = driver.providers(credentials) if driver.respond_to? :providers
      @driver = settings.drivers[@name]
      return [404, "Driver #{@name} not found"] unless @driver
      respond_to do |format|
        format.xml { haml :"drivers/show" }
        format.json { @driver.to_json }
        format.html { haml :"drivers/show" }
      end
    end
  end
end

collection :realms do
  description <<END
  Within a cloud provider a realm represents a boundary containing resources.
  The exact definition of a realm is left to the cloud provider.
  In some cases, a realm may represent different datacenters, different continents,
  or different pools of resources within a single datacenter.
  A cloud provider may insist that resources must all exist within a single realm in
  order to cooperate. For instance, storage volumes may only be allowed to be mounted to
  instances within the same realm.
END

  operation :index do
    description <<END
    Operation will list all available realms. Realms can be filtered using
    the "architecture" parameter.
END
    with_capability :realms
    param :id,            :string
    param :architecture,  :string,  :optional,  [ 'i386', 'x86_64' ]
    control { filter_all(:realms) }
  end

  #FIXME: It always shows whole list
  operation :show do
    description 'Show an realm identified by "id" parameter.'
    with_capability :realm
    param :id,           :string, :required
    control { show(:realm) }
  end

end

collection :images do
  description <<END
  An image is a platonic form of a machine. Images are not directly executable,
  but are a template for creating actual instances of machines.
END

  operation :new do
    description "Form to create a new image resource"
    param :instance_id, :string,  "An instance from which the new image will be created from"
    control do
      @instance = Instance.new( :id => params[:instance_id] )
      respond_to do |format|
        format.html { haml :"images/new" }
      end
    end
  end

  operation :index do
    description <<END
    The images collection will return a set of all images
    available to the current use. Images can be filtered using the
    "owner_id" and "architecture" parameters.
END
    with_capability :images
    param :id,            :string
    param :architecture,  :string,  :optional
    control { filter_all(:images) }
  end

  operation :show do
    description 'Show an image identified by "id" parameter.'
    with_capability :image
    param :id,           :string, :required
    control { show(:image) }
  end

  operation :create do
    description 'Create image from instance'
    with_capability :create_image
    param :instance_id,	 :string, :required
    param :name,	 :string, :optional
    param :description,	 :string, :optional
    control do
      @image = driver.create_image(credentials, {
	:id => params[:instance_id],
        :name => params[:name],
	:description => params[:description]
      })
      status 201  # Created
      response['Location'] = image_url(@image.id)
      respond_to do |format|
        format.xml  { haml :"images/show" }
        format.json { convert_to_json(:image, @image) }
        format.html { haml :"images/show" }
      end
    end
  end

  operation :destroy do
    description "Remove specified image from collection"
    with_capability :destroy_image
    param :id,    :string,    :required
    control do
      driver.destroy_image(credentials, params[:id])
      status 204
      respond_to do |format|
        format.xml
        format.json
        format.html { redirect(images_url) }
      end
    end
  end

end

collection :instance_states do
  description "The possible states of an instance, and how to traverse between them "

  operation :index do
    control do
      @machine = driver.instance_state_machine
      respond_to do |format|
        format.xml { haml :'instance_states/show', :layout => false }
        format.json do
          out = []
          @machine.states.each do |state|
            transitions = state.transitions.collect do |t|
              t.automatically? ? {:to => t.destination, :auto => 'true'} : {:to => t.destination, :action => t.action}
            end
            out << { :name => state, :transitions => transitions }
          end
          out.to_json
        end
        format.html { haml :'instance_states/show'}
        format.gv { erb :"instance_states/show" }
        format.png do
          # Trick respond_to into looking up the right template for the
          # graphviz file
          gv = erb(:"instance_states/show")
          png =  ''
          cmd = 'dot -Kdot -Gpad="0.2,0.2" -Gsize="5.0,8.0" -Gdpi="180" -Tpng'
          Open3.popen3( cmd ) do |stdin, stdout, stderr|
            stdin.write( gv )
            stdin.close()
            png = stdout.read
          end
          content_type 'image/png'
          png
        end
      end
    end
  end
end

get "#{settings.root_url}/instances/:id/run" do
  @instance = driver.instance(credentials, :id => params[:id])
  respond_to do |format|
    format.html { haml :"instances/run_command" }
  end
end

collection :load_balancers do
  description "Load balancers"

  operation :new do
    description "Form to create a new load balancer"
    control do
      @realms = driver.realms(credentials)
      @instances = driver.instances(credentials) if driver_has_feature?(:register_instance, :load_balancers)
      respond_to do |format|
        format.html { haml :"load_balancers/new" }
      end
    end
  end

  operation :index do
    description "List of all active load balancers"
    control do
      filter_all :load_balancers
    end
  end

  operation :show do
    description "Show details about given load balancer"
    param :id,  :string,  :required
    control { show :load_balancer }
  end

  operation :create do
    description "Create a new load balancer"
    param :name,  :string,  :required
    param :realm_id,  :string,  :required
    param :listener_protocol,  :string,  :required, ['HTTP', 'TCP']
    param :listener_balancer_port,  :string,  :required
    param :listener_instance_port,  :string,  :required
    control do
      @load_balancer = driver.create_load_balancer(credentials, params)
      status 201  # Created
      response['Location'] = load_balancer_url(@instance.id)
      respond_to do |format|
        format.xml  { haml :"load_balancers/show" }
        format.json { convert_to_json(:load_balancer, @load_balancer) }
        format.html { haml :"load_balancers/show" }
      end
    end
  end

  operation :register, :method => :post, :member => true do
    description "Add instance to loadbalancer"
    param :id,  :string,  :required
    param :instance_id, :string,  :required
    control do
      driver.lb_register_instance(credentials, params)
      status 204
      respond_to do |format|
        format.xml
        format.json
        format.html { redirect(load_balancer_url(params[:id])) }
      end
    end
  end

  operation :unregister, :method => :post, :member => true do
    description "Remove instance from loadbalancer"
    param :id,  :string,  :required
    param :instance_id, :string,  :required
    control do
      driver.lb_unregister_instance(credentials, params)
      status 204
      respond_to do |format|
        format.xml
        format.json
        format.html { redirect(load_balancer_url(params[:id])) }
      end
    end
  end

  operation :destroy do
    description "Destroy given load balancer"
    param :id,  :string,  :required
    control do
      driver.destroy_load_balancer(credentials, params[:id])
      status 204
      respond_to do |format|
        format.xml
        format.json
        format.html { redirect(load_balancers_url) }
      end
    end
  end

end


collection :instances do
  description <<END
  An instance is a concrete machine realized from an image.
  The images collection may be obtained by following the link from the primary entry-point.
END

  operation :new do
    description "Form for creating a new instance resource"
    param :image_id,  :string,  "Image from which will be the new instance created from"
    param :realm_id,  :string, :optional
    if driver_has_feature? :authentication_key
      param :authentication_key, :string, :optional
    end
    if driver_has_feature? :firewalls
      param :firewalls, :string, :optional
    end
    control do
      @instance = Instance.new( { :id=>params[:id], :image_id=>params[:image_id] } )
      @image   = Image.new( :id => params[:image_id] )
      @hardware_profiles = driver.hardware_profiles(credentials, :architecture => @image.architecture )
      @realms = [Realm.new(:id => params[:realm_id])] if params[:realm_id]
      @realms ||= driver.realms(credentials)
      @keys = driver.keys(credentials) if driver_has_feature?(:authentication_key)
      @firewalls = driver.firewalls(credentials) if driver_has_feature?(:firewalls)
      respond_to do |format|
        format.html do
          haml :'instances/new'
        end
      end
    end
  end

  operation :index do
    description "List all instances."
    with_capability :instances
    param :id,            :string,  :optional
    param :state,         :string,  :optional
    control { filter_all(:instances) }
  end

  operation :show do
    description 'Show an instance identified by "id" parameter.'
    with_capability :instance
    param :id,           :string, :required
    control { show(:instance) }
  end

  operation :create do
    description "Create a new instance."
    with_capability :create_instance
    param :image_id,     :string, :required
    param :realm_id,     :string, :optional
    param :hwp_id,       :string, :optional
    control do
      @instance = driver.create_instance(credentials, params[:image_id], params)
      status 201  # Created
      response['Location'] = instance_url(@instance.id)
      respond_to do |format|
        format.xml  { haml :"instances/show" }
        format.json { convert_to_json(:instance, @instance) }
        format.html do
          redirect instance_url(@instance.id) if @instance and @instance.id
          redirect instances_url
        end
      end
    end
  end

  operation :reboot, :method => :post, :member => true do
    description "Reboot a running instance."
    with_capability :reboot_instance
    param :id,           :string, :required
    control { instance_action(:reboot) }
  end

  operation :start, :method => :post, :member => true do
    description "Start an instance."
    with_capability :start_instance
    param :id,           :string, :required
    control { instance_action(:start) }
  end

  operation :stop, :method => :post, :member => true do
    description "Stop a running instance."
    with_capability :stop_instance
    param :id,           :string, :required
    control { instance_action(:stop) }
  end

  operation :destroy do
    description "Destroy an instance."
    with_capability :destroy_instance
    param :id,           :string, :required
    control { instance_action(:destroy) }
  end

  operation :run, :method => :post, :member => true do
    description <<END
  Run command on instance. Either password or private key must be send
  in order to execute command. Authetication method should be advertised
  in instance.
END
    with_capability :run_on_instance
    param :id,          :string,  :required
    param :cmd,         :string,  :required, [], "Shell command to run on instance"
    param :private_key, :string,  :optional, [], "Private key in PEM format for authentication"
    param :password,    :string,  :optional, [], "Password used for authentication"
    control do
      @output = driver.run_on_instance(credentials, params)
      respond_to do |format|
        format.xml { haml :"instances/run" }
        format.html { haml :"instances/run" }
      end
    end
  end
end

collection :hardware_profiles do
  description <<END
 A hardware profile represents a configuration of resources upon which a
 machine may be deployed. It defines aspects such as local disk storage,
 available RAM, and architecture. Each provider is free to define as many
 (or as few) hardware profiles as desired.
END

  operation :index do
    description "List of available hardware profiles."
    with_capability :hardware_profiles
    param :id,          :string
    param :architecture,  :string,  :optional,  [ 'i386', 'x86_64' ]
    control do
        @profiles = driver.hardware_profiles(credentials, params)
        respond_to do |format|
          format.xml  { haml :'hardware_profiles/index' }
          format.html  { haml :'hardware_profiles/index' }
          format.json { convert_to_json(:hardware_profile, @profiles) }
        end
    end
  end

  operation :show do
    description "Show specific hardware profile."
    with_capability :hardware_profile
    param :id,          :string,    :required
    control do
      @profile =  driver.hardware_profile(credentials, params[:id])
      if @profile
        respond_to do |format|
          format.xml { haml :'hardware_profiles/show', :layout => false }
          format.html { haml :'hardware_profiles/show' }
          format.json { convert_to_json(:hardware_profile, @profile) }
        end
      else
        report_error(404)
      end
    end
  end

end

collection :storage_snapshots do
  description "Storage snapshots description here"

  operation :new do
    description "A form to create a new storage snapshot"
    control do
      respond_to do |format|
        format.html { haml :"storage_snapshots/new" }
      end
    end
  end

  operation :index do
    description "List of storage snapshots."
    with_capability :storage_snapshots
    param :id,            :string
    control { filter_all(:storage_snapshots) }
  end

  operation :show do
    description "Show storage snapshot."
    with_capability :storage_snapshot
    param :id,          :string,    :required
    control { show(:storage_snapshot) }
  end

  operation :create do
    description "Create a new snapshot from volume"
    with_capability :create_storage_snapshot
    param :volume_id, :string,  :required
    control do
      @storage_snapshot = driver.create_storage_snapshot(credentials, params)
      status 201  # Created
      response['Location'] = storage_snapshot_url(@storage_snapshot.id)
      show(:storage_snapshot)
    end
  end

  operation :destroy do
    description "Delete storage snapshot"
    with_capability :destroy_storage_snapshot
    param :id,  :string,  :required
    control do
      driver.destroy_storage_snapshot(credentials, params)
      status 204
      respond_to do |format|
        format.xml
        format.json
        format.html { redirect(storage_snapshots_url) }
      end
    end
  end
end

collection :storage_volumes do
  description "Storage volumes description here"

  operation :new do
    description "A form to create a new storage volume"
    control do
      respond_to do |format|
        format.html { haml :"storage_volumes/new" }
      end
    end
  end

  operation :index do
    description "List of storage volumes."
    with_capability :storage_volumes
    param :id,            :string
    control { filter_all(:storage_volumes) }
  end

  operation :show do
    description "Show storage volume."
    with_capability :storage_volume
    param :id,          :string,    :required
    control { show(:storage_volume) }
  end

  operation :create do
    description "Create a new storage volume"
    with_capability :create_storage_volume
    param :snapshot_id, :string,  :optional
    param :capacity,    :string,  :optional
    param :realm_id,    :string,  :optional
    control do
      @storage_volume = driver.create_storage_volume(credentials, params)
      status 201
      response['Location'] = storage_volume_url(@storage_volume.id)
      respond_to do |format|
        format.xml  { haml :"storage_volumes/show" }
        format.html { haml :"storage_volumes/show" }
        format.json { convert_to_json(:storage_volume, @storage_volume) }
      end
    end
  end

  operation :attach_instance, :method=>:get, :member=>true  do
    description "A form to attach a storage volume to an instance"
    control do
      @instances = driver.instances(credentials)
      respond_to do |format|
        format.html{ haml :"storage_volumes/attach"}
      end
    end
  end

  operation :attach, :method => :post, :member => true do
    description "Attach storage volume to instance"
    with_capability :attach_storage_volume
    param :id,         :string,  :required
    param :instance_id,:string,  :required
    param :device,     :string,  :required
    control do
      @storage_volume = driver.attach_storage_volume(credentials, params)
      status 202
      respond_to do |format|
        format.html { redirect(storage_volume_url(params[:id]))}
        format.xml  { haml :"storage_volumes/show" }
        format.json { convert_to_json(:storage_volume, @storage_volume) }
      end
    end
  end

  operation :detach, :method => :post, :member => true do
    description "Detach storage volume to instance"
    with_capability :detach_storage_volume
    param :id,         :string,  :required
    control do
      volume = driver.storage_volume(credentials, :id => params[:id])
      @storage_volume =  driver.detach_storage_volume(credentials, :id => volume.id, :instance_id => volume.instance_id, :device => volume.device)
      status 202
      respond_to do |format|
        format.html { redirect(storage_volume_url(params[:id]))}
        format.xml  { haml :"storage_volumes/show" }
        format.json { convert_to_json(:storage_volume, @storage_volume) }
      end
    end
  end

  operation :destroy do
    description "Destroy storage volume"
    with_capability :destroy_storage_volume
    param :id,          :string,  :optional
    control do
      driver.destroy_storage_volume(credentials, params)
      status 204
      respond_to do |format|
        format.xml
        format.json
        format.html { redirect(storage_volumes_url) }
      end
    end
  end

end

collection :keys do
  description "Instance authentication credentials."

  operation :new do
    description "A form to create a new key resource"
    control do
      respond_to do |format|
        format.html { haml :"keys/new" }
      end
    end
  end

  operation :index do
    description "List all available credentials which could be used for instance authentication."
    with_capability :keys
    control do
      filter_all :keys
    end
  end

  operation :show do
    description "Show details about given instance credential."
    with_capability :key
    param :id,  :string,  :required
    control { show :key }
  end

  operation :create do
    description "Create a new instance credential if backend supports this."
    with_capability :create_key
    param :name,  :string,  :required
    control do
      @key = driver.create_key(credentials, { :key_name => params[:name] })
      status 201
      response['Location'] = key_url(@key.id)
      respond_to do |format|
        format.xml  { haml :"keys/show", :ugly => true }
        format.html { haml :"keys/show" }
        format.json { convert_to_json(:key, @key)}
      end
    end
  end

  operation :destroy do
    description "Destroy given instance credential if backend supports this."
    with_capability :destroy_key
    param :id,  :string,  :required
    control do
      driver.destroy_key(credentials, { :id => params[:id]})
      status 204
      respond_to do |format|
        format.xml
        format.json
        format.html { redirect(keys_url) }
      end
    end
  end

end

#get html form for creating a new blob

# The URL for getting the new blob form for the HTML UI looks like the URL
# for getting the details of an existing blob. To make collisions less
# likely, we use a name for the form that will rarely be the name of an
# existing blob
NEW_BLOB_FORM_ID = "new_blob_form_d15cfd90"

get "#{settings.root_url}/buckets/:bucket/#{NEW_BLOB_FORM_ID}" do
  @bucket_id = params[:bucket]
  respond_to do |format|
    format.html {haml :"blobs/new"}
  end
end

collection :buckets do
  description "Cloud Storage buckets - aka buckets|directories|folders"

  collection :blobs do
    description "Blobs associated with given bucket"

    operation :show do
      description "Display blob"
      control do
        @blob = driver.blob(credentials, { :id => params[:blob], 'bucket' => params[:bucket]})
        if @blob
          respond_to do |format|
            format.xml { haml :"blobs/show" }
            format.html { haml :"blobs/show" }
            format.json { convert_to_json(:blob, @blob) }
          end
        else
          report_error(404)
        end
      end

    end

    operation :create do
      description "Create new blob"
      control do
        bucket_id = params[:bucket]
        blob_id = params['blob_id']
        blob_data = params['blob_data']
        user_meta = {}
        #metadata from params (i.e., passed by http form post, e.g. browser)
        max = params[:meta_params]
        if(max)
          (1..max.to_i).each do |i|
            key = params[:"meta_name#{i}"]
            key = "HTTP_X_Deltacloud_Blobmeta_#{key}"
            value = params[:"meta_value#{i}"]
            user_meta[key] = value
          end
        end
        @blob = driver.create_blob(credentials, bucket_id, blob_id, blob_data, user_meta)
        respond_to do |format|
          format.xml { haml :"blobs/show" }
          format.html { haml :"blobs/show"}
        end
      end
    end

    operation :destroy do
      description "Destroy given blob"
      control do
        bucket_id = params[:bucket]
        blob_id = params[:blob]
        driver.delete_blob(credentials, bucket_id, blob_id)
        status 204
        respond_to do |format|
          format.xml
          format.json
          format.html { redirect(bucket_url(bucket_id)) }
        end
      end
    end

    operation :stream, :member => true, :standard => true, :method => :put do
      description "Stream new blob data into the blob"
      control do
        if(env["BLOB_SUCCESS"]) #ie got a 200ok after putting blob
          content_type = env["CONTENT_TYPE"]
          content_type ||=  ""
          @blob = driver.blob(credentials, {:id => params[:blob],
                                            'bucket' => params[:bucket]})
          respond_to do |format|
            format.xml { haml :"blobs/show" }
            format.html { haml :"blobs/show" }
            format.json { convert_to_json(:blob, @blob) }
          end
        elsif(env["BLOB_FAIL"])
          report_error(500) #OK?
        else # small blobs - < 112kb dont hit the streaming monkey patch - use 'normal' create_blob
          # also, if running under webrick don't hit the streaming patch (Thin specific)
          bucket_id = params[:bucket]
          blob_id = params[:blob]
          temp_file = Tempfile.new("temp_blob_file")
          temp_file.write(env['rack.input'].read)
          temp_file.flush
          content_type = env['CONTENT_TYPE'] || ""
          blob_data = {:tempfile => temp_file, :type => content_type}
          user_meta = BlobHelper::extract_blob_metadata_hash(request.env)
          @blob = driver.create_blob(credentials, bucket_id, blob_id, blob_data, user_meta)
          temp_file.delete
          respond_to do |format|
            format.xml { haml :"blobs/show" }
            format.html { haml :"blobs/show"}
          end
        end
      end
    end

    operation :metadata, :member => true, :standard => true, :method => :head do
      description "Get blob metadata"
      control do
        @blob_id = params[:blob]
        @blob_metadata = driver.blob_metadata(credentials, {:id => params[:blob], 'bucket' => params[:bucket]})
        if @blob_metadata
          @blob_metadata.each do |k,v|
            headers["X-Deltacloud-Blobmeta-#{k}"] = v
          end
          status 204
          respond_to do |format|
            format.xml
            format.json
          end
        else
          report_error(404)
        end
      end
    end

    operation :update, :member => true, :method => :post do
      description "Update blob metadata"
      control do
        meta_hash = BlobHelper::extract_blob_metadata_hash(request.env)
        success = driver.update_blob_metadata(credentials, {'bucket'=>params[:bucket], :id =>params[:blob], 'meta_hash' => meta_hash})
        if(success)
          meta_hash.each do |k,v|
            headers["X-Deltacloud-Blobmeta-#{k}"] = v
          end
          status 204
          respond_to do |format|
            format.xml
            format.json
          end
        else
          report_error(404) #FIXME is this the right error code?
        end
      end
    end

    operation :content, :member => true, :method => :get do
      description "Download blob content"
      control do
        @blob = driver.blob(credentials, { :id => params[:blob], 'bucket' => params[:bucket]})
        if @blob
          params['content_length'] = @blob.content_length
          params['content_type'] = @blob.content_type
          params['content_disposition'] = "attachment; filename=#{@blob.id}"
          BlobStream.call(env, credentials, params)
        else
          report_error(404)
        end
      end
    end

  end

  operation :new do
    description "A form to create a new bucket resource"
    control do
      respond_to do |format|
        format.html { haml :"buckets/new" }
      end
    end
  end

  operation :index do
    description "List buckets associated with this account"
    with_capability :buckets
    param :id,        :string
    param :name,      :string
    param :size,      :string
    control { filter_all(:buckets) }
  end

  operation :show do
    description "Show bucket"
    with_capability :bucket
    param :id,        :string
    control { show(:bucket) }
  end

  operation :create do
    description "Create a new bucket (POST /api/buckets)"
    with_capability :create_bucket
    param :name,      :string,    :required
    control do
      @bucket = driver.create_bucket(credentials, params[:name], params)
      status 201
      response['Location'] = bucket_url(@bucket.id)
      respond_to do |format|
        format.xml  { haml :"buckets/show" }
        format.json { convert_to_json(:bucket, @bucket) }
        format.html do
          redirect bucket_url(@bucket.id) if @bucket and @bucket.id
          redirect buckets_url
        end
      end
    end
  end

  operation :destroy do
    description "Delete a bucket by name - bucket must be empty"
    with_capability :delete_bucket
    param :id,    :string,    :required
    control do
      driver.delete_bucket(credentials, params[:id], params)
      status 204
      respond_to do |format|
        format.xml
        format.json
        format.html {  redirect(buckets_url) }
      end
    end
  end

end

get "#{settings.root_url}/addresses/:id/associate" do
  @instances = driver.instances(credentials)
  @address = Address::new(:id => params[:id])
  respond_to do |format|
    format.html { haml :"addresses/associate" }
  end
end

collection :addresses do
  description "Manage IP addresses"

  operation :index do
    description "List IP addresses assigned to your account."
    with_capability :addresses
    control do
      filter_all :addresses
    end
  end

  operation :show do
    description "Show details about IP addresses specified by given ID"
    with_capability :address
    param :id,  :string,  :required
    control { show :address }
  end

  operation :create do
    description "Acquire a new IP address for use with your account."
    with_capability :create_address
    control do
      @address = driver.create_address(credentials, {})
      status 201    # Created
      response['Location'] = address_url(@address.id)
      respond_to do |format|
        format.xml  { haml :"addresses/show", :ugly => true }
        format.html { haml :"addresses/_address", :layout => false }
        format.json { convert_to_json(:address, @address) }
      end
    end
  end

  operation :destroy do
    description "Release an IP address associated with your account"
    with_capability :destroy_address
    param :id,  :string,  :required
    control do
      driver.destroy_address(credentials, { :id => params[:id]})
      status 204
      respond_to do |format|
        format.xml
        format.json
        format.html { redirect(addresses_url) }
      end
    end
  end

  operation :associate, :method => :post, :member => true do
    description "Associate an IP address to an instance"
    with_capability :associate_address
    param :id, :string, :required
    param :instance_id, :string, :required
    control do
      driver.associate_address(credentials, { :id => params[:id], :instance_id => params[:instance_id]})
      status 202   # Accepted
      respond_to do |format|
        format.xml
        format.json
        format.html { redirect(address_url(params[:id])) }
      end
    end
  end

  operation :disassociate, :method => :post, :member => true do
    description "Disassociate an IP address from an instance"
    with_capability :associate_address
    param :id, :string, :required
    control do
      driver.disassociate_address(credentials, { :id => params[:id] })
      status 202   # Accepted
      respond_to do |format|
        format.xml
        format.json
        format.html { redirect(address_url(params[:id])) }
      end
    end
  end

end

#delete a firewall rule
delete '/api/firewalls/:firewall/:rule' do
  opts = {}
  opts[:firewall] = params[:firewall]
  opts[:rule_id] = params[:rule]
  driver.delete_firewall_rule(credentials, opts)
  status 204
  respond_to do |format|
    format.xml
    format.json
    format.html {redirect firewall_url(params[:firewall])}
  end
end

#FIREWALLS
collection :firewalls do
  description "Allow user to define firewall rules for an instance (ec2 security groups) eg expose ssh access [port 22, tcp]."

  operation :new do
    description "A form to create a new firewall resource"
    control do
      respond_to do |format|
        format.html { haml :"firewalls/new" }
      end
    end
  end

  operation :new_rule, :form => true, :member => true, :method => :get do
    description "A form to create a new firewall rule"
    param :id,  :string,  :required
    control do
      @firewall_name = params[:id]
      respond_to do |format|
        format.html {haml :"firewalls/new_rule" }
      end
    end
  end

  operation :index do
    description 'List all firewalls'
    with_capability :firewalls
    control { filter_all(:firewalls) }
  end

  operation :show do
    description 'Show details for a specific firewall - list all rules'
    with_capability :firewall
    param :id,            :string,    :required
    control { show(:firewall) }
  end

  operation :create do
    description 'Create a new firewall'
    with_capability :create_firewall
    param :name,          :string,    :required
    param :description,   :string,    :required
    control do
      @firewall = driver.create_firewall(credentials, params )
      status 201  # Created
      response['Location'] = firewall_url(@firewall.id)
      respond_to do |format|
        format.xml  { haml :"firewalls/show" }
        format.html { haml :"firewalls/show" }
        format.json { convert_to_json(:firewall, @firewall) }
      end
    end
  end

  operation :destroy do
    description 'Delete a specified firewall - error if firewall has rules'
    with_capability :delete_firewall
    param :id,            :string,    :required
    control do
      driver.delete_firewall(credentials, params)
      status 204
      respond_to do |format|
        format.xml
        format.json
        format.html {  redirect(firewalls_url) }
      end
    end
  end

  #create a new firewall rule - POST /api/firewalls/:firewall/rules
  operation :rules, :method => :post, :member => true do
    description 'Create a new firewall rule for the specified firewall'
    param :id,  :required, :string, [],  "Name of firewall in which to apply this rule"
    param :protocol,  :required, :string, ['tcp','udp','icmp'], "Transport layer protocol for the rule"
    param :port_from, :required, :string, [], "Start of port range for the rule"
    param :port_to,   :required, :string, [], "End of port range for the rule"
    with_capability :create_firewall_rule
    control do
      #source IPs from params
      addresses =  params.inject([]){|result,current| result << current.last unless current.grep(/^ip[-_]address/i).empty?; result}
      #source groups from params
      groups = {}
      max_groups  = params.select{|k,v| k=~/^group/}.size/2
      for i in (1..max_groups) do
        groups.merge!({params["group#{i}"]=>params["group#{i}owner"]})
      end
      params['addresses'] = addresses
      params['groups'] = groups
      if addresses.empty? && groups.empty?
        raise Deltacloud::Validation::Failure.new(nil, "No sources. Specify at least one source ip_address or group")
      end
      driver.create_firewall_rule(credentials, params)
      @firewall = driver.firewall(credentials, {:id => params[:id]})
      status 201
      respond_to do |format|
        format.xml  { haml :"firewalls/show" }
        format.html { haml :"firewalls/show" }
        format.json { convert_to_json(:firewall, @firewall) }
      end
    end
  end

end
