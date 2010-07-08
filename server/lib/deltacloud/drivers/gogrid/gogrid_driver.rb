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
require 'deltacloud/drivers/gogrid/gogrid_client'

module Deltacloud
  module Drivers
    module Gogrid

class GogridDriver < Deltacloud::BaseDriver

  # Storage capacity is same on all machines (10gb), it could be extended using 'Cloud Storage'
  define_hardware_profile('server-with-512mb-ram') do
    cpu              2
    memory         0.5
    storage        10
    architecture 'i386'
  end

  define_hardware_profile('server-with-1gb-ram') do
    cpu            2
    memory         1
    storage        10
    architecture   'i386'
  end

  define_hardware_profile('server-with-2gb-ram') do
    cpu            2
    memory         2
    storage        10
    architecture   'i386'
  end

  define_hardware_profile('server-with-4gb-ram') do
    cpu            2
    memory         4
    storage        10
    architecture   'i386'
  end

  define_hardware_profile('server-with-8gb-ram') do
    cpu            2
    memory         8
    storage        10
    architecture   'i386'
  end

  # The only valid option for flavors is server RAM for now
  def flavors(credentials, opts=nil)
    flavors = []
    safely do
      flavors=new_client(credentials).request('common/lookup/list', { 'lookup' => 'server.ram' })['list'].collect do |flavor|
        convert_flavor(flavor)
      end
    end
    flavors = filter_on( flavors, :id, opts )
    flavors = filter_on( flavors, :architecture, opts )
    flavors
  end

  def images(credentials, opts=nil)
    imgs = []
    if opts and opts[:id]
      safely do
        imgs = [convert_image(new_client(credentials).request('grid/image/get', { 'id' => opts[:id] })['list'].first)]
      end
    else
      safely do
        imgs = new_client(credentials).request('grid/image/list', { 'state' => 'Available'})['list'].collect do |image|
          convert_image(image, credentials.user)
        end
      end
    end
    imgs = filter_on( imgs, :architecture, opts )
    imgs.sort_by{|e| [e.owner_id, e.description]}
  end

  def realms(credentials, opts=nil)
    safely do
      new_client(credentials).request('common/lookup/list', { 'lookup' => 'image.type' })['list'].collect do |realm|
        convert_realm(realm)
      end
    end
  end

  def create_instance(credentials, image_id, opts=nil)
    flavor_id = opts[:flavor_id] || '1'
    name = (opts[:name] && opts[:name]!='') ? opts[:name] : get_random_instance_name
    safely do
      convert_instance(new_client(credentials).request('grid/server/add', { 
        'name' => name,
        'image' => image_id,
        'server.ram' => flavor_id,
        'ip' => get_next_free_ip(credentials)
      })['list'].first, credentials.user)
    end
  end

  def instances(credentials, opts=nil)
    instances = []
    if opts and opts[:id]
      safely do
        instance = new_client(credentials).request('grid/server/get', { 'id' => opts[:id]})['list'].first
        instances = [convert_instance(instance, credentials.user)]
      end
    else
      safely do
        instances = new_client(credentials).request('grid/server/list')['list'].collect do |instance|
          convert_instance(instance, credentials.user)
        end 
      end
    end
    instances = filter_on( instances, :state, opts )
    instances
  end

  def reboot_instance(credentials, id)
    safely do
      new_client(credentials).request('grid/server/power', { 'id' => id, 'power' => 'reboot'})
    end
  end

  def stop_instance(credentials, id)
    safely do
      new_client(credentials).request('grid/server/power', { 'id' => id, 'power' => 'off'})
    end
  end

  def destroy_instance(credentials, id)
    safely do
      new_client(credentials).request('grid/server/delete', { 'id' => id})
    end
  end

  define_instance_states do
    start.to( :pending )         .automatically
    pending.to( :running )       .automatically
    running.to( :stopped )       .on( :stop )
    stopped.to( :running )       .on( :start )
    stopped.to( :finish )        .automatically
  end

  private

  def new_client(credentials)
    GoGridClient.new('https://api.gogrid.com/api', credentials.user, credentials.password)
  end

  def convert_image(gg_image, owner_id=nil)
    Image.new( {
      :id=>gg_image['id'],
      :name => gg_image['friendlyName'],
      :description=> convert_description(gg_image),
      :owner_id=>gg_image['owner']['name'],
      :architecture=>convert_arch(gg_image['description']),
    } )
  end

  def convert_description(image)
    if image['price'].eql?(0)
      image['description']
    else
      "#{image['description']} (#{image['price']}$)"
    end
  end

  def convert_flavor(flavor)
    Flavor.new(
      :id => flavor['id'],
      :architecture => 'x86',
      :memory => flavor['name'].tr('G', ''),
      :storage => '1'
    )
  end

  def convert_realm(realm)
    Realm.new(
      :id => realm['id'],
      :name => realm['name'],
      :state => :unlimited,
      :storage => :unlimited
    )
  end

  def convert_arch(description)
    description.include?('64-bit') ? 'x86_64' : 'i386'
  end

  def convert_instance(instance, owner_id)
    Instance.new(
      :id => instance['id'],
      :owner_id => owner_id,
      :image_id => instance['image']['id'],
      :flavor_id => instance['ram']['id'],
      :name => instance['name'],
      :realm_id => instance['type']['id'],
      :state => convert_server_state(instance['state']['name'], instance['id']),
      :actions => instance_actions_for(convert_server_state(instance['state']['name'], instance['id'])),
      :public_addresses => [ instance['ip']['ip'] ],
      :private_addresses => []
    )
  end

  def get_random_instance_name
    "Server #{Time.now.to_i.to_s.reverse[0..3]}#{rand(9)}"
  end

  def convert_server_state(state, id)
    return 'PENDING' unless id
    state.eql?('Off') ? 'STOPPED' : 'RUNNING'
  end

  def get_next_free_ip(credentials)
    ip = ""
    safely do
      ip = new_client(credentials).request('grid/ip/list', { 
        'ip.type' => '1',
        'ip.state' => '1'
      })['list'].first['ip']
    end
    return ip
  end

  def safely(&block)
    begin
      block.call
    rescue Exception => e
      puts "ERROR: #{e.message}"
    end
  end

end

    end
  end
end


