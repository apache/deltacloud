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

Sinatra::Application.register Sinatra::RespondTo

# Redirect to /api
get '/' do redirect url_for('/api'); end

get '/api\/?' do
    @version = 0.1
    if params[:force_auth]
      return [401, 'Authentication failed'] unless driver.valid_credentials?(credentials)
    end
    respond_to do |format|
        format.xml { haml :"api/show" }
        format.json do
          { :api => {
            :version => @version,
            :driver => DRIVER,
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
  respond_to do |format|
    format.html { haml :"instances/new" }
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

get '/api/buckets/new' do
  respond_to do |format|
    format.html { haml :"buckets/new" }
  end
end


get '/api/buckets/:bucket/:blob/content' do
  @blob = driver.blob(credentials, { :id => params[:blob], 'bucket' => params[:bucket]})
  params['content_length'] = @blob.content_length
  params['content_type'] = @blob.content_type
  BlobStream.call(env, credentials, params)
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
