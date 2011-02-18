# Copyright (C) 2009, 2010  Red Hat, Inc.
#
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
require 'drivers'
require 'json'
require 'sinatra/respond_to'
require 'sinatra/static_assets'
require 'sinatra/rabbit'
require 'sinatra/lazy_auth'
require 'erb'
require 'haml'
require 'open3'
require 'lib/deltacloud/helpers/blob_stream'
require 'sinatra/rack_driver_select'
require 'sinatra/rack_runtime'
require 'sinatra/rack_etag'

set :version, '0.2.0'


use Rack::DriverSelect
use Rack::ETag
use Rack::Runtime

configure do
  set :raise_errors => false
  set :show_exceptions, false
  set :views, File.dirname(__FILE__) + '/views'
  set :public, File.dirname(__FILE__) + '/public'
end

configure :development do
  # So we can just use puts for logging
  $stdout.sync = true
  $stderr.sync = true
end

# You could use $API_HOST environment variable to change your hostname to
# whatever you want (eg. if you running API behind NAT)
HOSTNAME=ENV['API_HOST'] ? ENV['API_HOST'] : nil

error Deltacloud::Validation::Failure do
  report_error(400, "validation_failure")
end

error Deltacloud::BackendCapability::Failure do
  report_error(405, "backend_capability_failure")
end
error Deltacloud::AuthException do
  report_error(403, "auth_exception")
end

error Deltacloud::BackendError do
  report_error(500, "backend_error")
end

error Sinatra::Rabbit::UnsupportedCollectionException do
  report_error(404, "not_found")
end

Sinatra::Application.register Sinatra::RespondTo

# Redirect to /api
get '/' do redirect url_for('/api'), 301; end

get '/api/drivers\/?' do
  respond_to do |format|
    format.xml { haml :"api/drivers" }
    format.html { haml :"api/drivers" }
  end
end

get '/api\/?' do
  if params[:force_auth]
    return [401, 'Authentication failed'] unless driver.valid_credentials?(credentials)
  end
  respond_to do |format|
    format.xml { haml :"api/show" }
    format.json do
      { :api => {
          :version => settings.version,
          :driver => driver_symbol,
          :links => entry_points.collect { |l| { :rel => l[0], :href => l[1]} }
        }
      }.to_json
    end
    format.html { haml :"api/show" }
  end
end

# Rabbit DSL

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
  but are a template for creating actual instances of machines."
END

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
          format_backup = format
          format(:gv)
          gv = erb(:"instance_states/show")
          format(format_backup)
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

get "/api/instances/new" do
  @instance = Instance.new( { :id=>params[:id], :image_id=>params[:image_id] } )
  @image   = driver.image( credentials, :id => params[:image_id] )
  @hardware_profiles = driver.hardware_profiles(credentials, :architecture => @image.architecture )
  @realms = driver.realms(credentials)
  @keys = driver.keys(credentials) if driver_has_feature?(:authentication_key)
  if driver_has_feature?(:register_to_load_balancer)
    @load_balancers = driver.load_balancers(credentials)
  end
  respond_to do |format|
    format.html { haml :"instances/new" }
  end
end

get '/api/instances/:id/run' do
  @instance = driver.instance(credentials, :id => params[:id])
  respond_to do |format|
    format.html { haml :"instances/run_command" }
  end
end

get '/api/load_balancers/new' do
  @realms = driver.realms(credentials)
  @instances = driver.instances(credentials) if driver_has_feature?(:register_instance, :load_balancers)
  respond_to do |format|
    format.html { haml :"load_balancers/new" }
  end
end


collection :load_balancers do
  description "Load balancers"

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
      respond_to do |format|
        format.xml { haml :"load_balancers/show" }
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
      redirect(load_balancer_url(params[:id]))
    end
  end

  operation :unregister, :method => :post, :member => true do
    description "Remove instance from loadbalancer"
    param :id,  :string,  :required
    param :instance_id, :string,  :required
    control do
      driver.lb_unregister_instance(credentials, params)
      redirect(load_balancer_url(params[:id]))
    end
  end

  operation :destroy do
    description "Destroy given load balancer"
    param :id,  :string,  :required
    control do
      driver.destroy_load_balancer(credentials, params[:id])
      redirect(load_balancers_url)
    end
  end

end


collection :instances do
  description <<END
  An instance is a concrete machine realized from an image.
  The images collection may be obtained by following the link from the primary entry-point."
END

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
      @image = driver.image(credentials, :id => params[:image_id])
      instance = driver.create_instance(credentials, @image.id, params)
      respond_to do |format|
        format.xml do
          response.status = 201  # Created
          response['Location'] = instance_url(instance.id)
          @instance = instance
          haml :"instances/show"
        end
        format.html do
          redirect instance_url(instance.id) if instance and instance.id
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
    param :cmd,         :string,  :required, "Shell command to run on instance"
    param :private_key, :string,  :optional, "Private key in PEM format for authentication"
    param :password,    :string,  :optional, "Password used for authentication"
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
        report_error(404, 'not_found')
      end
    end
  end

end

get '/api/storage_snapshots/new' do
  respond_to do |format|
    format.html { haml :"storage_snapshots/new" }
  end
end

collection :storage_snapshots do
  description "Storage snapshots description here"

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
      show(:storage_snapshot)
    end
  end

  operation :destroy do
    description "Delete storage snapshot"
    with_capability :destroy_storage_snapshot
    param :id,  :string,  :required
    control do
      driver.create_storage_snapshot(credentials, params)
      redirect(storage_snapshot_url(params[:id]))
    end
  end

end

get '/api/storage_volumes/new' do
  respond_to do |format|
    format.html { haml :"storage_volumes/new" }
  end
end

get '/api/storage_volumes/attach' do
  respond_to do |format|
    @instances = driver.instances(credentials)
    format.html { haml :"storage_volumes/attach" }
  end
end

collection :storage_volumes do
  description "Storage volumes description here"

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
      respond_to do |format|
        format.html { haml :"storage_volumes/show" }
        format.xml { haml :"storage_volumes/show" }
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
      driver.attach_storage_volume(credentials, params)
      redirect(storage_volume_url(params[:id]))
    end
  end

  operation :detach, :method => :post, :member => true do
    description "Detach storage volume to instance"
    with_capability :detach_storage_volume
    param :id,         :string,  :required
    control do
      volume = driver.storage_volume(credentials, :id => params[:id])
      driver.detach_storage_volume(credentials, :id => volume.id, :instance_id => volume.instance_id,
                                   :device => volume.device)
      redirect(storage_volume_url(params[:id]))
    end
  end

  operation :destroy do
    description "Destroy storage volume"
    with_capability :destroy_storage_volume
    param :id,          :string,  :optional
    control do
      driver.destroy_storage_volume(credentials, params)
      redirect(storage_volumes_url)
    end
  end

end

get '/api/keys/new' do
  respond_to do |format|
    format.html { haml :"keys/new" }
  end
end

collection :keys do
  description "Instance authentication credentials."

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
      respond_to do |format|
        format.html { haml :"keys/show" }
        format.xml { haml :"keys/show", :ugly => true }
      end
    end
  end

  operation :destroy do
    description "Destroy given instance credential if backend supports this."
    with_capability :destroy_key
    param :id,  :string,  :required
    control do
      driver.destroy_key(credentials, { :key_name => params[:id]})
      redirect(keys_url)
    end
  end

end

#get html form for creating a new blob
get '/api/buckets/:bucket/new_blob' do
  @bucket_id = params[:bucket]
  respond_to do |format|
    format.html {haml :"blobs/new"}
  end
end

#create a new blob
post '/api/buckets/:bucket' do
  bucket_id = params[:bucket]
  blob_id = params['blob_id']
  blob_data = params['blob_data']
  user_meta = {}
#first try get blob_metadata from params (i.e., passed by http form post, e.g. browser)
  max = params[:meta_params]
  if(max)
    (1..max.to_i).each do |i|
      key = params[:"meta_name#{i}"]
      key = "HTTP_X_Deltacloud_Blobmeta_#{key}"
      value = params[:"meta_value#{i}"]
      user_meta[key] = value
    end #max.each do
  else #can try to get blob_metadata from http headers
    meta_array = request.env.select{|k,v| k.match(/^HTTP[-_]X[-_]Deltacloud[-_]Blobmeta[-_]/i)}
    meta_array.inject({}){ |result, array| user_meta[array.first.upcase] = array.last}
  end #end if
  @blob = driver.create_blob(credentials, bucket_id, blob_id, blob_data, user_meta)
  respond_to do |format|
    format.html { haml :"blobs/show"}
    format.xml { haml :"blobs/show" }
  end
end

#delete a blob
delete '/api/buckets/:bucket/:blob' do
  bucket_id = params[:bucket]
  blob_id = params[:blob]
  driver.delete_blob(credentials, bucket_id, blob_id)
  redirect(bucket_url(bucket_id))
end

#get blob metadata
head '/api/buckets/:bucket/:blob' do
  @blob_id = params[:blob]
  @blob_metadata = driver.blob_metadata(credentials, {:id => params[:blob], 'bucket' => params[:bucket]})
  if @blob_metadata
      @blob_metadata.each do |k,v|
        headers["X-Deltacloud-Blobmeta-#{k}"] = v
      end
   else
    report_error(404, 'not_found')
  end
end

#update blob metadata
post '/api/buckets/:bucket/:blob' do
  meta_hash = {}
  request.env.inject({}){|current, (k,v)| meta_hash[k] = v if k.match(/^HTTP[-_]X[-_]Deltacloud[-_]Blobmeta[-_]/i)}
  success = driver.update_blob_metadata(credentials, {'bucket'=>params[:bucket], :id =>params[:blob], 'meta_hash' => meta_hash})
  if(success)
    meta_hash.each do |k,v|
      headers["X-Deltacloud-Blobmeta-#{k}"] = v
    end
  else
    report_error(404, 'not_found') #FIXME is this the right error code?
  end
end

#Get a particular blob's particulars (not actual blob data)
get '/api/buckets/:bucket/:blob' do
  @blob = driver.blob(credentials, { :id => params[:blob], 'bucket' => params[:bucket]})
  if @blob
    respond_to do |format|
      format.html { haml :"blobs/show" }
      format.xml { haml :"blobs/show" }
      format.json { convert_to_json(blobs, @blob) }
      end
  else
      report_error(404, 'not_found')
  end
end

#get the content of a particular blob
get '/api/buckets/:bucket/:blob/content' do
  @blob = driver.blob(credentials, { :id => params[:blob], 'bucket' => params[:bucket]})
  if @blob
    params['content_length'] = @blob.content_length
    params['content_type'] = @blob.content_type
    params['content_disposition'] = "attachment; filename=#{@blob.id}"
    BlobStream.call(env, credentials, params)
  else
    report_error(404, 'not_found')
  end
end

#Get html form for creating a new bucket
get '/api/buckets/new' do
  respond_to do |format|
    format.html { haml :"buckets/new" }
  end
end

collection :buckets do
  description "Cloud Storage buckets - aka buckets|directories|folders"

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
      respond_to do |format|
        format.xml do
          response.status = 201  # Created
          response['Location'] = bucket_url(@bucket.id)
          haml :"buckets/show"
        end
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
      redirect(buckets_url)
    end
  end

end
