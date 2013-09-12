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

require 'rubygems'
require 'profitbricks'

module Deltacloud
  module Drivers
    module Profitbricks

class ProfitbricksDriver < Deltacloud::BaseDriver

  define_hardware_profile('default') do
    cpu              1..48,                            :default => 1
    memory           (1..196*4).collect { |i| i*256 }, :default => 1024
    storage          20..2048,                         :default => 50
    architecture     'x86_64'
  end

  def images(credentials, opts = {})
    new_client(credentials)
    results = []
    safely do
      #get all HDD images - filter by HDD, because only HDD images can be attached to a storage
      results = ::Profitbricks::Image.all.select { | img | img.type == 'HDD'}.collect do | img |
        Image.new(
            :id => img.id,
            :name => img.name,
            :description => "CPU Hot-Plugging: #{img.cpu_hotpluggable}, Region: #{img.region}, Os: (#{img.os_type}), Type: #{img.type}",
            :owner_id => credentials.user,
            :state => 'AVAILABLE',
            :architecture => 'x86_64',
        )
      end
    end
    # Add hardware profiles to each image
    profiles = hardware_profiles(credentials)
    results.each { |img| img.hardware_profiles = profiles }
    filter_on( results, opts, :id, :region, :name)
  end

  def realms(credentials, opts = {})
    new_client(credentials)
    results = []
    safely do
      datacenters = if opts[:image] != nil
        ::Profitbricks::DataCenter.all.select { |dc| opts[:image].description.include? dc.region }
      else
        ::Profitbricks::DataCenter.all
      end
      results = datacenters.collect do |data_center|
        convert_data_center(data_center)
      end
    end
    filter_on(results, :id, opts)
  end

  def instances(credentials, opts = {})
    new_client(credentials)

    results = safely do
      if opts[:storage_id]
        storage = ::Profitbricks::Storage.find(:id => opts[:storage_id])
        ::Profitbricks::DataCenter.find(:id => storage.data_center_id).servers.collect do |s|
          convert_instance(s, credentials.user)
        end
      else
        ::Profitbricks::Server.all.collect do |s|
          convert_instance(s, credentials.user)
        end
      end
    end
    filter_on(results, opts, :id, :state, :realm_id)
    results
  end

  def create_instance( credentials, image_id, opts)
    new_client(credentials)
    params = {}
    storage = nil
    server = nil

    safely do
      #Create storage first
      if opts[:hwp_storage]
        params[:name] = "Storage#{rand(1000)}"
        params[:size] = opts.delete("hwp_storage")
        params[:mount_image_id] = opts.delete("image_id")
        if opts[:realm_id]
          params[:data_center_id] = opts[:realm_id]
        end
        storage = convert_storage(::Profitbricks::Storage.create(params))
      end

      #Create instange
      opts.delete("hwp_id");
      opts[:name] = opts.delete('name');
      opts[:name] = opts[:name] == "" ? "Sever#{rand(1000)}" : opts[:name]
      opts[:ram] = opts.delete("hwp_memory")
      opts[:cores] = opts.delete("hwp_cpu")
      opts[:availability_zone] = "AUTO"
      opts[:internet_access] = true
      opts[:lan_id] = "1"
      if storage.respond_to?('id')
        opts[:boot_from_storage_id] = storage.id
      end
      opts[:data_center_id] = opts.delete("realm_id")
      if opts[:data_center_id] == nil && storage.respond_to?('realm_id')
        opts[:data_center_id] = storage.realm_id
      end
      server = convert_instance(::Profitbricks::Server.create(opts), credentials.user)
    end
    server
  end


  def reboot_instance( credentials, instance_id )
    new_client(credentials)
    safely do
      server = ::Profitbricks::Server.find(:id => instance_id)
      server.reset
    end
  end

  def stop_instance( credentials, instance_id )
    new_client(credentials)
    safely do
      server = ::Profitbricks::Server.find(:id => instance_id)
      server.stop
    end
  end

  def start_instance( credentials, instance_id )
    new_client(credentials)
    safely do
      server = ::Profitbricks::Server.find(:id => instance_id)
      server.start
    end
  end

  def destroy_instance( credentials, instance_id )
    new_client(credentials)
    safely do
      server = ::Profitbricks::Server.find(:id => instance_id)
      server.delete
    end
  end


  def storage_volumes( credentials, opts = {} )
    new_client(credentials)
    results = safely do
      if opts[:id]
        [convert_storage(::Profitbricks::Storage.find(:id => opts[:id]))]
      else
        ::Profitbricks::DataCenter.all.collect do |data_center|
          (data_center.storages || []).collect do |storage|
            convert_storage(storage)
          end.flatten
        end.flatten
      end
    end
    results
  end


  def create_storage_volume(credentials, opts = {})
    new_client(credentials)
    result = nil
    params = {}
    safely do
      opts[:size] = opts.delete("capacity") || 1
      opts[:data_center_id] = opts.delete("realm_id") unless (opts["realm_id"].nil? || opts["realm_id"].empty?)
      opts[:name] = opts.delete("name") || "Storage#{rand(1000)}"
      opts.delete("commit")
      opts.delete("snapshot_id")
      opts.delete("description")
      result = convert_storage(::Profitbricks::Storage.create(opts))
    end
    result
  end

  def destroy_storage_volume(credentials, opts = {})
    new_client( credentials )
    safely do
      storage = ::Profitbricks::Storage.find(:id => opts[:id])
      storage.delete
    end
  end

  def attach_storage_volume( credentials, opts = {} )
    new_client( credentials )
    safely do
      storage = ::Profitbricks::Storage.find(:id => opts[:id])
      storage.connect(:server_id => opts[:instance_id])
    end
  end

  def detach_storage_volume(credentials, opts = {})
    new_client( credentials )
    safely do
      storage = ::Profitbricks::Storage.find(:id => opts[:id])
      storage.disconnect(:server_id => opts[:instance_id])
    end
  end

  def create_load_balancer(credentials, opts={})
    new_client(credentials)
    safely do
      load_balancer = ::Profitbricks::LoadBalancer.create(:name => opts[:name], :data_center_id => opts[:realm_id])
      load_balancer(credentials, :id => load_balancer.id)
    end
  end

  def load_balancer(credentials, opts = {})
    new_client(credentials)
    safely do
      load_balancer = ::Profitbricks::LoadBalancer.find(:id => opts[:id])
      data_center = ::Profitbricks::DataCenter.find(:id => load_balancer.data_center_id)
      convert_load_balancer(load_balancer, data_center)
    end
  end

  def load_balancers(credentials, opts = {})
    new_client(credentials)
    safely do
      ::Profitbricks::DataCenter.all.collect do |data_center|
        (data_center.load_balancers || []).collect do |lb|
          convert_load_balancer(lb, data_center)
        end.flatten
      end.flatten
    end
  end

  def lb_register_instance(credentials, opts={})
    new_client(credentials)
    safely do
      load_balancer = ::Profitbricks::LoadBalancer.find(:id => opts[:id])
      server        = ::Profitbricks::Server.find(:id => opts[:instance_id])
      load_balancer.register_servers([server])
      load_balancer(credentials, :id => opts[:id])
    end
  end

  def lb_unregister_instance(credentials, opts={})
    new_client(credentials)
    safely do
      load_balancer = ::Profitbricks::LoadBalancer.find(:id => opts[:id])
      server        = ::Profitbricks::Server.find(:id => opts[:instance_id])
      load_balancer.deregister_servers([server])
      load_balancer(credentials, :id => opts[:id])
    end
  end

  def destroy_load_balancer(credentials, id)
    new_client(credentials)
    safely do
      load_balancer = ::Profitbricks::LoadBalancer.find(:id => id)
      load_balancer.delete
    end
  end

  def firewalls(credentials, opts={})
    new_client(credentials)
    safely do
      ::Profitbricks::Server.all.collect do |server|
        (server.nics || []).collect do |nic|
          convert_firewall(nic.firewall) if nic.firewall
        end.flatten.compact
      end.flatten
    end
  end

  def create_firewall(credentials, opts={})
    # TODO is this even possible?
    raise "Error"
  end

  def delete_firewall(credentials, opts={})
    new_client(credentials)
    safely do
      firewall = ::Profitbricks::Firewall.find(:id => opts[:id])
      firewall.delete
    end
  end

  def create_firewall_rule(credentials, opts={})
    new_client(credentials)
    safely do
      firewall = ::Profitbricks::Firewall.find(:id => opts[:id])
      rules = opts[:addresses].collect do |source_ip|
        ::Profitbricks::FirewallRule.new({
          :protocol => opts[:protocol],
          :port_range_start => opts[:port_from],
          :port_range_end => opts[:port_to],
          :source_ip => source_ip.split('/').first,
          :target_ip => '0.0.0.0'
        })
      end
      firewall.add_rules(rules)
    end
  end

  def delete_firewall_rule(credentials, opts={})
    new_client(credentials)
    safely do
      ::Profitbricks::Firewall.find(:id => opts[:firewall]).rules.select { |rule|
        rule.id == opts[:rule_id]
      }.first.delete
    end
  end

  def address(credentials, opts={})
    new_client(credentials)
    servers = safely do
      ::Profitbricks::Server.all()
    end
    convert_ip_block(find_ip_block_by_ip(opts[:id]), servers)
  end

  def addresses(credentials, opts={})
    new_client(credentials)
    safely do
      servers = ::Profitbricks::Server.all()
      ::Profitbricks::IpBlock.all().collect do |ip_block|
        convert_ip_block(ip_block, servers)
      end
    end
  end

  def create_address(credentials, opts={})
    new_client(credentials)
    safely do
      convert_ip_block(::Profitbricks::IpBlock.reserve(1))
    end
  end

  def destroy_address(credentials, opts={})
    new_client(credentials)
    safely do
      ip_block = find_ip_block_by_ip(opts[:id])
      ip_block.release
    end
  end

  def associate_address(credentials, opts={})
    new_client(credentials)
    safely do
      ip_block = find_ip_block_by_ip(opts[:id])
      server = ::Profitbricks::Server.find(:id => opts[:instance_id])
      server.nics.first.add_ip(opts[:id])
      convert_ip_block(ip_block)
    end
  end

  def disassociate_address(credentials, opts={})
    new_client(credentials)
    safely do
      ip_block = find_ip_block_by_ip(opts[:id])
      servers = ::Profitbricks::Server.all()
      result = convert_ip_block(ip_block, servers)
      server = ::Profitbricks::Server.find(:id => result.instance_id)
      server.nics.first.remove_ip(opts[:id])
      result
    end
  end

  def network_interfaces(credentials, opts = {})
    new_client(credentials)
    safely do
      ::Profitbricks::Server.all.select { | server| server.nics!=nil}.collect do |server|
        server.nics.collect do |nic|
          convert_network_interface(nic)
        end.flatten
      end.flatten
    end
  end

  def create_network_interface(credentials, opts={})
    new_client(credentials)
    safely do
      opts[:server_id] = opts.delete("instance");
      opts[:lan_id] = opts[:network].nil?? "1" : opts.delete("network");
      opts[:name] = opts[:name].nil?? "eth#{rand(100)}" : opts.delete("name");
      convert_network_interface(::Profitbricks::Nic.create(opts))
    end
  end

  def destroy_network_interface(credentials, nic_id)
    new_client(credentials)
    safely do
      nic = ::Profitbricks::Nic.find({:id => nic_id})
      nic.delete
    end
  end

  def networks(credentials, opts = {})
    new_client(credentials)
    safely do
      ::Profitbricks::Server.all.select { | server| server.nics!=nil}.collect do |server|
        server.nics.collect do |nic|
          Network.new({
            :id => nic.lan_id,
            :name => "Lan #{nic.lan_id} (Datacenter #{server.data_center_id})"
          })
        end.flatten
      end.flatten
    end
  end

  define_instance_states do
    start.to( :pending )          .automatically
    pending.to( :running )        .automatically

    stopped.to( :running )        .on( :start )
    stopped.to( :stopped )        .on( :destroy )

    running.to( :running )        .on( :reboot )
    running.to( :stopping )       .on( :stop )

    stopping.to(:stopped)         .automatically
    stopping.to(:finish)          .automatically
    stopped.to( :finish )         .automatically
  end

  #
  ### Private declarations
  #

  private

  def convert_instance(server, user_name)
    inst = Instance.new(
      :id                => server.id,
      :realm_id          => server.data_center_id,
      :owner_id          => user_name,
      :description       => server.name,
      :name              => server.name,
      :state             => convert_instance_state(server),
      :architecture      => 'x86_64',
      :image_id          => find_instance_image(server),
      :instance_profile  => InstanceProfile::new('default'),
      :public_addresses  => server.public_ips,
      :private_addresses => server.private_ips,
      :username          => nil,
      :password          => nil,
      :storage_volumes => convert_instance_storages_volumes(server)
    )
    inst.actions = instance_actions_for( inst.state )
    inst
  end

  def convert_instance_state(server)
    state = server.respond_to?('virtual_machine_state')? (server.provisioned?? server.virtual_machine_state : server.provisioning_state) : "ERROR"
    case state
      when /INPROCESS/
        "PENDING"
      when /SHUTOFF/
        "STOPPED"
      when /SHUTDOWN/
        "STOPPED"
      when /PAUSED/
        "STOPPED"
      when /INACTIVE/
        "STOPPED"
      when /CRASHED/
        "ERROR"
      when /NOSTATE/
        "ERROR"
      when /ERROR/
        "ERROR"
      when /RUNNING/
        "RUNNING"
      else
        "UNKNOWN"
    end
  end

  def convert_instance_storages_volumes(server)
    return [] if server.connected_storages.nil?
    server.connected_storages.collect { |s| {s.id => nil} }
  end

  def find_instance_image(server)
    return nil if server.connected_storages.nil?
    server.connected_storages.each do |s|
      # FIXME due to the api not returning the bootDevice flag we just use the first image we find
      storage = ::Profitbricks::Storage.find(id: s.id)
      return storage.mount_image.id if storage.mount_image
    end
    return nil
  end

  def convert_storage (storage)
    result = StorageVolume.new(
        :id => storage.id,
        :name => storage.respond_to?(:name) ? storage.name : 'unknown',
        :description => "Capacity: #{storage.size}GB",
        :state => convert_storage_state(storage),
        :capacity => storage.size,
        :realm_id => storage.data_center_id,
        :actions => [:attach, :detach, :destroy]
    )
    if storage.respond_to?("server_ids")
      result.instance_id= storage.server_ids
    end
    if storage.respond_to?("creation_time")
      result.created = storage.creation_time
    end
    result
  end

  def convert_storage_state(storage)
    state = storage.respond_to?('provisioning_state')? storage.provisioning_state : "ERROR"
    case state
      when /INPROCESS/
        "PENDING"
      when /INACTIVE/
        "ERROR"
      when /ERROR/
        "ERROR"
      when /AVAILABLE/
        "AVAILABLE"
      else
        "UNKNOWN"
    end
  end

  def convert_data_center(data_center)
    Realm.new(
      :id => data_center.id,
      :name => "#{data_center.name} (#{data_center.region})",
      :state => 'AVAILABLE', # ProfitBricks doesn't return the states when calling getAllDataCenters()
      :limit => :unlimited
    )
  end

  def convert_load_balancer(lb, dc)
    realms = []
    balancer = LoadBalancer.new({
      :id => lb.id,
      :name => lb.name,
      :created_at => lb.creation_time,
      :public_addresses => [lb.ip],
      :realms => [convert_data_center(dc)],
      :instances => lb.balanced_servers ? lb.balanced_servers.collect { |s| convert_instance(s, "") } : [],
      :listeners => []
    })
    balancer
  end

  def convert_network_interface(nic)
    net = NetworkInterface.new({
      :id => nic.id,
      :name => nic.name,
      :state => "UP",
      :instance => nic.server_id,
      :network => nic.lan_id,
      :ip_address => nic.ips.first
    })
  end

  def convert_firewall(firewall)
    Firewall.new({
      :id => firewall.id,
      :description => "Firewall of #{firewall.nic_id}",
      :owner_id => firewall.nic_id,
      :rules => firewall.rules ? firewall.rules.collect { |r| convert_firewall_rule(r)} : []
    })
  end

  def convert_firewall_rule(rule)
    FirewallRule.new({
      :id => rule.id,
      :allow_protocol => rule.protocol,
      :port_from => rule.port_range_start,
      :port_to => rule.port_range_end,
      :sources => [{:type => "address", :family=>"ipv4",
                    :address=>rule.source_ip,
                    :prefix=>''}],
      :direction => 'ingress',
    })
  end

  def convert_ip_block(ip_block, servers = [])
    server = servers.select do |server|
      server.public_ips.include? ip_block.ips.first
    end.first
    Address.new({
      :id => ip_block.ips.first,
      :instance_id => server ? server.id : nil
    })
  end

  def find_ip_block_by_ip(ip)
    ::Profitbricks::IpBlock.all().each do |ip_block|
      return ip_block if ip_block.ips.include? ip
    end
  end

  def new_client(credentials)
    client = nil
    safely do
      ::Profitbricks.configure do |config|
        config.username = credentials.user
        config.password = credentials.password
      end
    end
  end

  exceptions do
    on /Failed to authenticate/ do
      status 401
    end

    on /Error/ do
      status 500
    end
  end
end

    end
  end
end

