#
# Copyright (C) 2009  Red Hat, Inc.
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

  define_hardware_profile '512MB' do
    cpu            0.5
    memory         512
    storage        30
  end

  define_hardware_profile '1GB' do
    cpu            1
    memory         1
    storage        60
  end

  define_hardware_profile '2GB' do
    cpu            2
    memory         2
    storage        120
  end

  define_hardware_profile '4GB' do
    cpu            4
    memory         4
    storage        240
  end

  define_hardware_profile '8GB' do
    cpu            8
    memory         8
    storage        480
  end

  def supported_collections
    DEFAULT_COLLECTIONS.reject! { |c| [ :storage_volumes, :storage_snapshots ].include?(c) }
    DEFAULT_COLLECTIONS + [ :keys ]
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
    image = image(credentials, :id => image_id )
    if opts && opts[:hwp_id]
      hwp = find_hardware_profile(credentials, opts[:hwp_id], image.id)
    else
      hwp = find_hardware_profile(credentials, "512MB", image.id)
    end

    client = new_client(credentials)
    name = (opts[:name] && opts[:name]!='') ? opts[:name] : get_random_instance_name
    if name.length > 20
      raise Deltacloud::BackendError.new(400, "name-too-long", "Name '#{name}' is too long; the maximum for GoGrid is 20 characters", nil)
    end
    safely do
      instance = client.request('grid/server/add', {
        'name' => name,
        'image' => image_id,
        'server.ram' => hwp.name,
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
          # getting a full listing and filtering on the id.  This could
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

  def key(credentials, opts=nil)
    keys(credentials, opts).first
  end

  def keys(credentials, opts=nil)
    gogrid = new_client( credentials )
    creds = []
    gogrid.request('support/password/list')['list'].each do |password|
      creds << convert_key(password)
    end
    return creds
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

  def convert_key(password)
    Key.new({
      :id => password['id'],
      :username => password['username'],
      :password => password['password'],
      :credential_type => :password
    })
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
    hwp_name = instance['image']['name']

    Instance.new(
       # note that we use 'name' as the id here, because newly created instances
       # don't get a real ID until later on.  The name is good enough; from
       # what I can tell, 'name' per user is unique, so it should be sufficient
       # to uniquely identify this instance.
      :id => instance['name'],
      :owner_id => owner_id,
      :image_id => instance['image']['id'],
      :instance_profile => InstanceProfile.new(hwp_name),
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
      raise Deltacloud::BackendError.new(500, e.class.to_s, e.message, e.backtrace)
    end
  end

end

    end
  end
end
