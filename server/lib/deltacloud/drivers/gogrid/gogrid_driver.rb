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

class Instance
  attr_accessor :username
  attr_accessor :password
  attr_accessor :authn_error

  def authn_feature_failed?
    return true unless authn_error.nil?
  end
end

module Deltacloud
  module Drivers
    module Gogrid

class GogridDriver < Deltacloud::BaseDriver

  feature :instances, :authentication_password

  define_hardware_profile 'server' do
    cpu            2
    memory         [512, 1024, 2048, 4096, 8192]
    storage        10
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
    server_ram = nil
    if opts[:hwp_memory]
      mem = opts[:hwp_memory].to_i
      server_ram = (mem == 512) ? "512MB" : "#{mem / 1024}GB"
    else
      server_ram = "512MB"
    end
    client = new_client(credentials)
    name = (opts[:name] && opts[:name]!='') ? opts[:name] : get_random_instance_name
    safely do
      instance = client.request('grid/server/add', {
        'name' => name,
        'image' => image_id,
        'server.ram' => server_ram,
        'ip' => get_next_free_ip(credentials)
      })['list'].first
      if instance
        login_data = get_login_data(client, instance[:id])
        if login_data['username'] and login_data['password']
          instance['username'] = login_data['username']
          instance['password'] = login_data['password']
          inst = convert_instance(instance, credentials.user)
        else
          inst = convert_instance(instance, credentials.user)
          inst.authn_error = "Unable to fetch password"
        end
        return inst
      else
        return nil
      end
    end
  end

  def list_instances(credentials, id)
    instances = []
    safely do
      new_client(credentials).request('grid/server/list')['list'].collect do |instance|
        if id.nil? or instance['name'] == id
          instances << convert_instance(instance, credentials.user)
        end
      end
    end
    instances
  end

  def instances(credentials, opts=nil)
    instances = []
    if opts and opts[:id]
      begin
        client = new_client(credentials)
        instance = client.request('grid/server/get', { 'name' => opts[:id] })['list'].first
        login_data = get_login_data(client, instance['id'])
        if login_data['username'] and login_data['password']
          instance['username'] = login_data['username']
          instance['password'] = login_data['password']
          inst = convert_instance(instance, credentials.user)
        else
          inst = convert_instance(instance, credentials.user)
          inst.authn_error = "Unable to fetch password"
        end
        instances = [inst]
      rescue Exception => e
        if e.message == "400 Bad Request"
          # in the case of a VM that we just made, the grid/server/get method
          # throws a "400 Bad Request error".  In this case we try again by
          # getting a full listing a filtering on the id.  This could
          # potentially take a long time, but I don't see another way to get
          # information about a newly created instance
          instances = list_instances(credentials, opts[:id])
        end
      end
    else
      instances = list_instances(credentials, nil)
    end
    instances = filter_on( instances, :state, opts )
    instances
  end

  def reboot_instance(credentials, id)
    safely do
      new_client(credentials).request('grid/server/power', { 'id' => id, 'power' => 'reboot'})
    end
  end

  def destroy_instance(credentials, id)
    safely do
      new_client(credentials).request('grid/server/delete', { 'id' => id})
    end
  end

  def stop_instance(credentials, id)
    safely do
      new_client(credentials).request('grid/server/power', { 'id' => id, 'power' => 'off'})
    end
  end

  def start_instance(credentials, id)
    safely do
      new_client(credentials).request('grid/server/power', { 'id' => id, 'power' => 'on'})
    end
  end

  define_instance_states do
    start.to( :pending )         .automatically
    pending.to( :running )       .automatically
    running.to( :stopped )       .on( :stop )
    stopped.to( :running )       .on( :start )
    running.to( :finish )       .on( :destroy )
    stopped.to( :finish )       .on( :destroy )
  end

  private

  def new_client(credentials)
    GoGridClient.new('https://api.gogrid.com/api', credentials.user, credentials.password)
  end

  def get_login_data(client, instance_id)
    login_data = {}
    begin
      client.request('support/password/list')['list'].each do |passwd|
        next unless passwd['server']
        if passwd['server']['id'] == instance_id
          login_data['username'], login_data['password'] = passwd['username'], passwd['password']
          break
        end
      end
    rescue Exception => e
      login_data[:error] = e.message
    end
    return login_data
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
    opts = {}
    unless instance['ram']['id'] == "1"
      mem = instance['ram']['name']
      if mem == "512MB"
        opts[:hwp_memory] = "512"
      else
        opts[:hwp_memory] = (mem.to_i * 1024).to_s
      end
    end
    prof = InstanceProfile.new("server", opts)

    Instance.new(
      :id => instance['id'],
      :owner_id => owner_id,
      :image_id => instance['image']['id'],
      :flavor_id => instance['ram']['id'],
      :instance_profile => prof,
      :name => instance['name'],
      :realm_id => instance['type']['id'],
      :state => convert_server_state(instance['state']['name'], instance['id']),
      :actions => instance_actions_for(convert_server_state(instance['state']['name'], instance['id'])),
      :public_addresses => [ instance['ip']['ip'] ],
      :private_addresses => [],
      :username => instance['username'],
      :password => instance['password']
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
