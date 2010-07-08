#
# Copyright (C) 2009  Red Hat, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require 'deltacloud/base_driver'
require 'deltacloud/drivers/rackspace/rackspace_client'

module Deltacloud
  module Drivers
    module Rackspace

class RackspaceDriver < Deltacloud::BaseDriver

  feature :instances, :user_name

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
    results = filter_on( results, :architecture, opts )
    results
  end

  def hardware_profiles(credentials, opts = nil)
    racks = new_client( credentials )
    results = racks.list_flavors.map do |flav|
      HardwareProfile.new(flav["id"].to_s) do
        architecture 'x86_64'
        memory flav["ram"].to_i
        storage flav["disk"].to_i
      end
    end
    filter_hardware_profiles(results, opts)
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
    results = filter_on( results, :id, opts )
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
    hwp_id = opts[:hwp_id] || 1
    name = Time.now.to_s
    if (opts[:name]) then name = opts[:name] end
    convert_srv_to_instance(racks.start_server(image_id, hwp_id, name))
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
    instances = filter_on( instances, :id, opts )
    instances = filter_on( instances, :state, opts )
    instances
  end


  def convert_srv_to_instance(srv)
    status = srv["status"] == "ACTIVE" ? "RUNNING" : "PENDING"
    inst = Instance.new(:id => srv["id"].to_s,
                        :owner_id => "root",
                        :realm_id => "us")
    inst.name = srv["name"]
    inst.state = srv["status"] == "ACTIVE" ? "RUNNING" : "PENDING"
    inst.actions = instance_actions_for(inst.state)
    inst.image_id = srv["imageId"].to_s
    inst.flavor_id = srv["flavorId"].to_s
    inst.instance_profile = InstanceProfile.new(srv["flavorId"].to_s)
    if srv["addresses"]
      inst.public_addresses  = srv["addresses"]["public"]
      inst.private_addresses = srv["addresses"]["private"]
    end
    inst
  end

  def new_client(credentials)
    RackspaceClient.new(credentials.user, credentials.password)
  end

  define_instance_states do
    start.to( :pending )          .on( :create )

    pending.to( :running )        .automatically

    running.to( :running )        .on( :reboot )
    running.to( :shutting_down )  .on( :stop )

    shutting_down.to( :stopped )  .automatically

    stopped.to( :finish )         .automatically
  end

end

    end
  end
end
