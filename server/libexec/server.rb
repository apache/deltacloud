require 'rubygems'
require 'deltacloud'
require 'sinatra'
require 'sinatra/respond_to'
require 'erb'
require 'haml'
require 'open3'
require 'builder'
require 'drivers'
require 'sinatra/static_assets'
require 'sinatra/rabbit'
require 'sinatra/validation'
require 'sinatra/lazy_auth'

configure do
  set :raise_errors => false
end

configure :development do
  # So we can just use puts for logging
  $stdout.sync = true
  $stderr.sync = true
end

DRIVER=ENV['API_DRIVER'] ? ENV['API_DRIVER'].to_sym : :mock

# You could use $API_HOST environment variable to change your hostname to
# whatever you want (eg. if you running API behind NAT)
HOSTNAME=ENV['API_HOST'] ? ENV['API_HOST'] : nil

Rack::Mime::MIME_TYPES.merge!({ ".gv" => "text/plain" })

module Sinatra
  register Sinatra::RespondTo
end

# Common actions
#

def filter_all(model)
    filter = {}
    filter.merge!(:id => params[:id]) if params[:id]
    filter.merge!(:architecture => params[:architecture]) if params[:architecture]
    filter.merge!(:owner_id => params[:owner_id]) if params[:owner_id]
    filter = nil if filter.keys.size.eql?(0)
    safely do
      singular = model.to_s.singularize.to_sym
      @elements = driver.send(model.to_sym, credentials, filter)
      instance_variable_set(:"@#{model}", @elements)
      respond_to do |format|
        format.xml  { return convert_to_xml(singular, @elements) }
        format.html { haml :"#{model}/index" }
      end
    end
end

def show(model)
  safely do
    @element = driver.send(model, credentials, { :id => params[:id]} )
    instance_variable_set("@#{model}", @element)
    respond_to do |format|
      format.xml { return convert_to_xml(model, @element) }
      format.html { haml :"#{model.to_s.pluralize}/show" }
    end
  end
end

# Redirect to /api
get '/' do redirect '/api'; end

get '/api\/?' do
    @version = 1.0
    respond_to do |format|
        format.html { haml :"api/show" }
        format.xml { haml :"api/show" }
    end
end

# Rabbit DSL

collection :flavors do
  description "Flavors are yummy"

  operation :index do
    description 'This action will do...'
    param :architecture,  :string,  :optional,  [ 'i386', 'x86_64' ]
    param :id,            :string,  :optional
    control { filter_all(:flavors) }
  end

  operation :show do
    description "Show a flavor"
    param :id,           :string, :required
    control { show(:flavor) }
  end

end

collection :realms do
  description "Realms are usefull"

  operation :index do
    description "List all realms"
    param :id,            :string
    param :architecture,  :string,  :optional,  [ 'i386', 'x86_64' ]
    control { filter_all(:realms) }
  end

  #FIXME: It always shows whole list
  operation :show do
    description "Show a realm"
    param :id,           :string, :required
    control { show(:realm) }
  end

end

collection :images do
  description "Operating system Images"

  operation :index do
    description "List of all deployable images"
    param :id,            :string
    param :owner_id,      :string
    param :architecture,  :string,  :optional,  [ 'i386', 'x86_64' ]
    control { filter_all(:images) }
  end

  operation :show do
    description "Show an image"
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
        format.html { haml :'instance_states/show'}
        format.gv { erb :"instance_states/show" }
        format.png do
          # Trick respond_to into looking up the right template for the
          # graphviz file
          format(:gv); gv = erb :"instance_states/show"; format(:png)
          png =  ''
          cmd = 'dot -Kdot -Gpad="0.2,0.2" -Gsize="5.0,8.0" -Gdpi="180" -Tpng'
          Open3.popen3( cmd ) do |stdin, stdout, stderr|
            stdin.write( gv )
            stdin.close()
            png = stdout.read
          end
          png
        end
      end
    end
  end
end

# Special instance get operations that we only allow for HTML
get "/api/instances/:id/:action" do
   meth = :"#{params[:action]}_instance"
   not_found unless driver.respond_to?(meth)
   respond_to do |format|
     format.html do
       driver.send(meth, credentials, params[:id])
       if params[:action] == 'destroy'
         redirect instances_url
       else
         redirect instance_url(params[:id])
       end
     end
   end
end

get "/api/instances/new" do
  @instance = Instance.new( { :id=>params[:id], :image_id=>params[:image_id] } )
  @image   = driver.image( credentials, :id => params[:image_id] )
  @flavors = driver.flavors( credentials, { :architecture=>@image.architecture } )
  @realms = driver.realms(credentials)
  respond_to do |format|
    format.html { haml :"instances/new" }
  end
end

def instance_action(name)
  safely do
    @instance = driver.send(:"#{name}_instance", credentials, params[:id])
    respond_to do |format|
      format.xml { return convert_to_xml(:instance, @instance) }
      format.html { haml :"instances/show" }
    end
  end
end

collection :instances do
  description "Instances description will go here"

  operation :index do
    description "List of instances"
    param :id,            :string
    control { filter_all(:instances) }
  end

  operation :show do
    description "Show an instance"
    param :id,           :string, :required
    control { show(:instance) }
  end

  operation :create do
    description "Create a new instance"
    param :image_id,     :string, :required
    param :realm_id,     :string, :optional
    param :flavor_id,    :string, :optional
    # FIXME: name is really a driver-specific feature
    param :name,         :string, :optional
    control do
      @image = driver.image(credentials, :id => params[:image_id])
      instance = driver.create_instance(credentials, @image.id, params)
      respond_to do |format|
        format.html { redirect instance_url(instance.id) }
        format.xml do
          response.status = 201  # Created
          response['Location'] = instance_url(instance.id)
          convert_to_xml(:instance, instance)
        end
      end
    end
  end

  operation :reboot, :method => :post, :member => true do
    description "Reboot running instance"
    param :id,           :string, :required
    control { instance_action(:reboot) }
  end

  operation :start, :method => :post, :member => true do
    description "Start an instance"
    param :id,           :string, :required
    control { instance_action(:start) }
  end

  operation :stop, :method => :post, :member => true do
    description "Stop running instance"
    param :id,           :string, :required
    control { instance_action(:stop) }
  end

  operation :destroy do
    description "Destroy instance"
    param :id,           :string, :required
    control { instance_action(:destroy) }
  end
end

collection :hardware_profiles do
  description "Hardware profiles"

  operation :index do
    description "List of available hardware profiles"
    param :id,          :string
    control do
        @profiles = driver.hardware_profiles
        respond_to do |format|
          format.xml  { convert_to_xml(:hardware_profiles, @profiles) }
          format.html  { haml :'hardware_profiles/index' }
        end
    end
  end

  operation :show do
    description "Show specific hardware profile"
    param :id,          :string,    :required
    control do
      @profile =  driver.hardware_profile(params[:id])
      respond_to do |format|
        format.xml { haml :'hardware_profiles/show', :layout => false }
        format.html { haml :'hardware_profiles/show' }
      end
    end
  end

end

collection :storage_snapshots do
  description "Storage snapshots description here"

  operation :index do
    description "Listing of storage snapshots"
    param :id,            :string
    control { filter_all(:storage_snapshots) }
  end

  operation :show do
    description "Show storage snapshot"
    param :id,          :string,    :required
    control { show(:storage_snapshot) }
  end
end

collection :storage_volumes do
  description "Storage volumes description here"

  operation :index do
    description "Listing of storage volumes"
    param :id,            :string
    control { filter_all(:storage_volumes) }
  end

  operation :show do
    description "Show storage volume"
    param :id,          :string,    :required
    control { show(:storage_volume) }
  end
end
