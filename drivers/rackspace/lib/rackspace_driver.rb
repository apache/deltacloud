require 'deltacloud/base_driver'
require 'rackspace_client'

class RackspaceDriver < DeltaCloud::BaseDriver

  def flavors(credentials, opts=nil)
    racks = new_client( credentials )
    results = racks.list_flavors.map do |flav|
      Flavor.new( {
                    :id=> flav["id"].to_s,
                    :memory=>flav["ram"].to_f/1024,
                    :storage=>flav["disk"].to_i,
                    :architecture=>'x86_64'
                  } )    
    end
    results = filter_on( results, :id, opts )
    results
  end

  def images(credentials, opts=nil)
    racks = new_client( credentials )
    results = racks.list_images.map do |img|
      Image.new( {
                   :id=>img["id"].to_s,
                   :name=>img["name"],
                   :description => img["name"] + " " + img["status"] + "",
                   :owner_id=>"root",
                   :architecture=>'x86_64'
                 } )
    end
    results.sort_by{|e| [e.description]}
    results
  end

  #rackspace does not at this stage have realms... its all US/TX, all the time (at least at time of writing) 
  def realms(credentials, opts=nil)
    [Realm.new( {
      :id=>"us",
      :name=>"United States",
      :state=> "AVAILABLE"
    } )]
  end

  def reboot_instance(credentials, id)
    racks = new_client(credentials)
    racks.reboot_server(id)
  end

  def stop_instance(credentials, id)
    destroy_instance(credentials, id)
  end

  def destroy_instance(credentials, id)
    racks = new_client(credentials)
    racks.delete_server(id)
  end


  #
  # create instance. Default to flavor 1 - really need a name though...
  # In rackspace, all flavors work with all images. 
  # 
  def create_instance(credentials, image_id, opts)
    racks = new_client( credentials )
    flavor_id = 1
    if (opts[:flavor_id]) then flavor_id = opts[:flavor_id] end
    name = Time.now.to_s
    if (opts[:name]) then name = opts[:name] end
    convert_srv_to_instance(racks.start_server(image_id, flavor_id, name)) 
  end

  #
  # Instances
  #
  def instances(credentials, opts=nil)
    racks = new_client(credentials)
    instances = []
    if (opts.nil?)
      instances = racks.list_servers.map do |srv| 
        convert_srv_to_instance(srv)
      end
    else 
      instances << convert_srv_to_instance(racks.load_server_details(opts[:id]))
    end
    instances
  end


  def convert_srv_to_instance(srv) 
            Instance.new( {
                            :id=>srv["id"],
                            :state=>srv["status"] == "ACTIVE" ? "RUNNING" : "PENDING",
                            :name=>srv["name"],
                            :image_id=>srv["imageId"],
                            :owner_id=>"root",
                            :realm_id=>"us",
                            :public_addresses=>( srv["addresses"]["public"] ),
                            :private_addresses=>( srv["addresses"]["private"] ),
                            :flavor_id=>srv["flavorId"],
                            :actions=>instance_actions_for(srv["status"] == "ACTIVE" ? "RUNNING" : "PENDING"),
                          } )
  end


  def new_client(credentials)
    if ( credentials[:name].nil? || credentials[:password].nil? || credentials[:name] == '' || credentials[:password] == '' )
      raise DeltaCloud::AuthException.new
    end
    RackspaceClient.new(credentials[:name], credentials[:password])
  end

  @@INSTANCE_STATES = [
    [ :begin, { 
        :pending=>:create,
    } ],
    [ :pending, { 
        :running=>:_auto_, 
    } ],
    [ :running, { 
        :running=>:reboot, 
        :shutting_down=>:stop
    } ],
    [ :shutting_down, { 
        :stopped=>:_auto_,
    } ],
    [ :stopped, {
        :end=>:_auto_,
    } ],
  ]

  def instance_states()
    @@INSTANCE_STATES 
  end


#PENDING
#STOPPED
#RUNNING

end
