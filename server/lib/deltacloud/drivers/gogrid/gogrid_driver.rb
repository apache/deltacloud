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

  feature :instances, :user_name do
    { :max_length => 20 }
  end

  feature :instances, :authentication_password
  feature :instances, :sandboxing

  define_hardware_profile 'default'

  USER_NAME_MAX = constraints(:collection => :instances, :feature => :user_name)[:max_length]

  def hardware_profiles(credentials, opts={})
    client = new_client(credentials)
    safely do
      server_types = client.request('common/lookup/list', { 'lookup' => 'server.type' })
      server_rams = client.request('common/lookup/list', { 'lookup' => 'server.ram' })
      @hardware_profiles = []
      server_types['list'].each do |type|
        memory_values = server_rams['list'].collect do |r|
            r['name'] =~ /MB$/ ? r['name'].gsub(/MB$/, '').to_i : (r['name'].gsub(/(\w{2})$/, '')).to_i*1024
        end
        @hardware_profiles << ::Deltacloud::HardwareProfile.new(type['name'].tr(' ', '-').downcase) do
          cpu 2
          memory memory_values
          storage 25
        end
      end
    end
    @hardware_profiles
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
    realms = []
    client = new_client(credentials)
    safely do
        client.request('common/lookup/list', { 'lookup' => 'ip.datacenter' })['list'].collect do |realm|
         realms << convert_realm(realm)
      end
    end
    realms = filter_on(realms, :id, opts)
  end

  def create_instance(credentials, image_id, opts={})
    server_ram = nil
    if opts[:hwp_memory]
      mem = opts[:hwp_memory].to_i
      server_ram = (mem == 512) ? "512MB" : "#{mem / 1024}GB"
    else
      server_ram = "512MB"
    end

    name = opts[:name]
    if not name
      name = "Server #{Time.now.to_i.to_s.reverse[0..3]}#{rand(9)}"
    end

    if name.length > USER_NAME_MAX
      raise "Parameter name must be #{USER_NAME_MAX} characters or less"
    end

    client = new_client(credentials)
    params = {
      'name' => name,
      'image' => image_id,
      'server.ram' => server_ram,
      'ip' => get_free_ip_from_realm(credentials, opts[:realm_id] || '1')
    }
    params.merge!('isSandbox' => 'true') if opts[:sandbox]
    safely do
      instance = client.request('grid/server/add', params)['list'].first
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

  def run_on_instance(credentials, opts={})
    target = instance(credentials, opts[:id])
    param = {}
    param[:credentials] = {
      :username => target.username,
      :password => target.password,
    }
    param[:credentials].merge!({ :password => opts[:password]}) if opts[:password].length>0
    param[:port] = opts[:port] || '22'
    param[:ip] = opts[:ip] || target.public_addresses.first.address
    Deltacloud::Runner.execute(opts[:cmd], param)
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
      new_client(credentials).request('grid/server/power', { 'name' => id, 'power' => 'reboot'})
    end
  end

  def destroy_instance(credentials, id)
    safely do
      new_client(credentials).request('grid/server/delete', { 'name' => id})
    end
  end

  def stop_instance(credentials, id)
    safely do
      new_client(credentials).request('grid/server/power', { 'name' => id, 'power' => 'off'})
    end
  end

  def start_instance(credentials, id)
    safely do
      new_client(credentials).request('grid/server/power', { 'name' => id, 'power' => 'on'})
    end
  end

 def create_load_balancer(credentials, opts={})
    gogrid = new_client(credentials)
    balancer, l_instance = nil, nil
    safely do
      virtip = get_free_ip_from_realm(credentials, opts['realm_id'])
      if opts['instance_id']
        l_instance = instance(credentials, :id => opts['instance_id'])
        real_ip = {
          'realiplist.0.port' => opts['listener_instance_port'].to_i,
          'realiplist.0.ip' => l_instance ? l_instance.public_addresses.first : ""
        }
      else
        real_ip = false
      end
      request = {
        'name' => opts['name'],
        'virtualip.ip' => virtip,
        'virtualip.port' => opts['listener_balancer_port'].to_i,
      }
      request.merge!(real_ip) if real_ip
      balancer = gogrid.request('grid/loadbalancer/add', request)['list'].first
    end
    balancer = convert_load_balancer(credentials, balancer)
    balancer.instances = [l_instance] if l_instance
    balancer
  end

  def destroy_load_balancer(credentials, id)
    gogrid = new_client(credentials)
    balancer = nil
    safely do
      balancer = gogrid.request('grid/loadbalancer/delete', { 'name' => id })
    end
  end

  def load_balancers(credentials, opts={})
    gogrid = new_client(credentials)
    balancers = []
    safely do
      balancer = gogrid.request('grid/loadbalancer/list', opts || {})['list'].each do |balancer|
        balancers << balancer
      end
    end
    balancers.collect { |b| convert_load_balancer(credentials, b) }
  end

  def load_balancer(credentials, opts={})
    gogrid = new_client(credentials)
    balancer = nil
    begin
      balancer = gogrid.request('grid/loadbalancer/get', { 'name' => opts[:id] })['list'].first
      balancer['instances'] = instances(credentials)
      return convert_load_balancer(credentials, balancer)
    rescue OpenURI::HTTPError
      balancer = load_balancers(credentials, :id => opts[:id]).first
    end
  end


  def lb_register_instance(credentials, opts={})
    client = new_client(credentials)
    instance = instance(credentials, :id => opts[:instance_id])
    balancer = client.request('grid/loadbalancer/get', { 'name' => opts[:id]})['list'].first
    safely do
      convert_load_balancer(credentials, client.request('grid/loadbalancer/edit', {
        "id" => balancer['id'],
        "realiplist.#{balancer['realiplist'].size}.ip" => instance.public_addresses.first,
        "realiplist.#{balancer['realiplist'].size}.port" => balancer['virtualip']['port']
      }))
    end
  end

  # Move this to capabilities
  def lb_unregister_instance(credentials, opts={})
      raise Deltacloud::BackendFeatureUnsupported.new('501',
    'Unregistering instances from load balancer is not supported in GoGrid')
  end

  def key(credentials, opts=nil)
    keys(credentials, opts).first
  end

  def keys(credentials, opts=nil)
    gogrid = new_client( credentials )
    creds = []
    safely do
      gogrid.request('support/password/list')['list'].each do |password|
        creds << convert_key(password)
      end
    end
    return creds
  end

  def valid_credentials?(credentials)
    client = new_client(credentials)
    # FIXME: We need to do this call to determine if
    #        GoGrid is working with given credentials. There is no
    #        other way to check, if given credentials are valid or not.
    return false unless new_client(credentials).request('common/lookup/list', { 'lookup' => 'ip.datacenter' })
    true
  end

  define_instance_states do
    start.to( :pending )         .automatically
    pending.to( :running )       .automatically
    running.to( :stopped )       .on( :stop )
    stopped.to( :running )       .on( :start )
    running.to( :finish )       .on( :destroy )
    stopped.to( :finish )       .on( :destroy )
  end

  def catched_exceptions_list
    {
      :auth => [ /Forbidden/ ],
      :error => [ /Error/ ],
      :glob => [ /(.*)/ ]
    }
  end

  private

  def new_client(credentials)
    GoGridClient.new('https://api.gogrid.com/api', credentials.user, credentials.password)
  end

  def convert_load_balancer(credentials, loadbalancer)
    if loadbalancer['datacenter']
      b_realm = realm(credentials, :id => loadbalancer['datacenter']['id'].to_s)
    else
      # Report first Realm until loadbalancer become ready
      b_realm = realm(credentials, :id => 1)
    end
    balancer = LoadBalancer.new({
      :id => loadbalancer['name'],
      :realms => [b_realm]
    })
    balancer.public_addresses = [loadbalancer['virtualip']['ip']['ip']] if loadbalancer['virtualip'] and loadbalancer['virtualip']['ip']
    balancer.listeners = []
    balancer.instances = []
    instance_ips = []
    if loadbalancer['realiplist'].size > 0
      loadbalancer['realiplist'].each do |instance_ip|
       balancer.add_listener({
          :protocol => 'TCP',
          :load_balancer_port => loadbalancer['virtualip']['port'],
          :instance_port => instance_ip['port']
        })
        instance_ips << instance_ip['ip']['ip']
      end
    else
      balancer.add_listener({:protocol=>'TCP', :load_balancer_port =>loadbalancer['virtualip']['port'],
                             :instance_port => "unassigned"})
    end
    balancer.instances = get_load_balancer_instances(instance_ips, loadbalancer['instances']) if loadbalancer['instances']
    return balancer
  end

  def get_load_balancer_instances(instance_ips, instances)
    instances.select { |i| instance_ips.include?(i.public_addresses.first) } if instances
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
      :name => "#{gg_image['friendlyName']}",
      :description=> convert_description(gg_image).to_s,
      :owner_id=>gg_image['owner']['name'].to_s,
      :architecture=>convert_arch(gg_image['description']),
      :state => gg_image['state']['name'].upcase
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
      :id => realm['id'].to_s,
      :name => realm['name'],
      :state => :unlimited,
      :storage => :unlimited
    )
  end

  def convert_arch(description)
    return 'i386' unless description
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
    hwp_name = instance['image']['name']
    state = convert_server_state(instance['state']['name'], instance['id'])

    Instance.new(
       # note that we use 'name' as the id here, because newly created instances
       # don't get a real ID until later on.  The name is good enough; from
       # what I can tell, 'name' per user is unique, so it should be sufficient
       # to uniquely identify this instance.
      :id => instance['name'],
      :owner_id => owner_id,
      :image_id => "#{instance['image']['id']}",
      :instance_profile => prof,
      :name => instance['name'],
      :realm_id => instance['ip']['datacenter']['id'],
      :state => state,
      :actions => instance_actions_for(state),
      :public_addresses => [ InstanceAddress.new(instance['ip']['ip']) ],
      :private_addresses => [],
      :username => instance['username'],
      :password => instance['password'],
      :create_image => 'true'.eql?(instance['isSandbox'])
    )
  end

  def convert_server_state(state, id)
    return 'PENDING' unless id
    state.eql?('Off') ? 'STOPPED' : 'RUNNING'
  end

  def get_free_ip_from_realm(credentials, realm_id, ip_type = 1)
    ip = ""
    safely do
      ip = new_client(credentials).request('grid/ip/list', {
        'ip.type' => "#{ip_type}",
        'ip.state' => '1',
        'datacenter' => realm_id
      })['list'].first['ip']
    end
    return ip
  end


end

    end
  end
end
