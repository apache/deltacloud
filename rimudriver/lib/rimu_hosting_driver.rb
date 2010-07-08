require "rimuhosting_client"
require "deltacloud/base_driver"

class RimuHostingDriver < DeltaCloud::BaseDriver
  def images(credentails, opts=nil)
    rh = new_client(credentails)
    images = rh.list_images.map do | image |
      Image.new({
                  :id => image["distro_code"],
                  :name => image["distro_code"],
                  :description => image["distro_description"],
                  :owner_id => "root",
                  :architecture => "x86"
              })
    end
    images.sort_by{|e| [e.description]}
    images = filter_on( images, :id, opts)
    images
  end

  def flavors(credentials, opts=nil)
    rh = new_client(credentials)
    flavors = rh.list_plans.map do | flavor |
      Flavor.new({
                  :id => flavor["pricing_plan_code"],
                  :memory => flavor["minimum_memory_mb"].to_f/1024,
                  :storage => flavor["minimum_disk_gb"].to_i,
                  :architecture => "x86"
                })
    end
    flavors = filter_on( flavors, :id, opts)
    flavors
  end

  def realms(credentials, opts=nil)
    [Realm.new( {
      :id=>"rimu",
      :name=>"RimuHosting",
      :state=> "AVAILABLE"
    } )]
  end
  
  def instances(credentials, opts=nil)
    rh = new_client(credentials)
    instances = rh.list_nodes.map do | inst |
      convert_srv_to_instance(inst)
    end
    instances = filter_on( instances, :id, opts)
    instances
  end
  def reboot_instance(credentials, id)
    rh = new_client(credentials)
    rh.set_server_state(id, :RESTARTING)
  end

  def start_instance(credentials, id)
    rh = new_client(credentials)
    rh.set_server_state(id, :STARTED)
  end

  def stop_instance(credentials, id)
    destroy_instance(credentials, id)
  end

  def destroy_instance(credentials, id)
    rh = new_client(credentials)
    rh.delete_server(id)
  end
  
  def create_instance(credentials, image_id, opts)
    rh = new_client( credentials )
    # really need to raise an exception here.
    flavor_id = 1
    if (opts[:flavor_id]) then flavor_id = opts[:flavor_id] end
    # really bad, but at least its a fqdn
    name = Time.now.to_s + '.com'
    if (opts[:name]) then name = opts[:name] end
    convert_srv_to_instance(rh.start_server(image_id, flavor_id, name))

    
  end

  def convert_srv_to_instance( inst )
     Instance.new({
                  :id => inst["order_oid"].to_s,
                  :name => inst["domain_name"],
                  :image_id => "lenny",
                  :state => "RUNNING",
                  :name => inst["domain_name"],
                  :realm_id => "RH",
                  :owner_id => "root",
                  :flavor_id => "none",
                  :actions => instance_actions_for("RUNNING")
              })
  end
  def instance_states
    [
      [ :begin, { :running => :_auto_ }],
      [ :pending, { :running => :_auto_ }],
      [ :running, { :running => :reboot, :shutting_down => :stop}],
      [ :shutting_down, { :stopped => :_auto_}],
      [ :stopped, { :end => :_auto_}]    
    ]
  end
  def new_client(credentials)
    if (credentials[:password].nil? || credentials[:password] == '' || credentials[:name].nil? || credentials[:name] == '')
      raise DeltaCloud::AuthException.new
    end
 
    RimuHostingClient.new(credentials[:name], credentials[:password])
  end
end