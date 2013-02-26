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
#

require "savon"

HTTPI.log = false


module Deltacloud
  module Drivers
    module Arubacloud

class ArubacloudDriver < Deltacloud::BaseDriver

  DEFAULT_DC = 'dc1'
  feature :instances, :authentication_password
  feature :instances, :user_name

  define_instance_states do
    start.to( :pending )         .automatically
    pending.to( :running )       .automatically
    running.to( :running )       .on( :reboot)
    running.to( :stopping )       .on( :stop )
    stopping.to( :stopped )       .automatically
    stopped.to( :pending )       .on( :start )
    stopped.to( :finish )        .on( :destroy )
  end

  define_hardware_profile 'VMWare' do
    cpu         ( 1..8 )
    memory      ( 1024 .. 32*1024 )
    storage     ( 10 .. 500)
    architecture ['x86_64', 'i386']
  end

  define_hardware_profile 'HyperV' do
    cpu         ( 1..4 )
    memory      ( 1024 .. 16*1024 )
    storage     ( 10 .. 500 )
    architecture ['x86_64', 'i386']
  end

  define_hardware_profile 'HyperVLowCost' do
    cpu         ( 1..4 )
    memory      ( 1024 .. 16*1024 )
    storage     ( 10 .. 500)
    architecture ['x86_64', 'i386']
  end

  def realms(credentials, opts=nil)
    client = new_client(credentials)
    safely do
      datacenters = get_all(client,
                            :datacenter_configurations,
                            :datacenter_config).inject([]) do |res, dc|
        res << Realm.new(
          :id => dc[:datacenter_id],
          :name => dc[:name],
          :limit => :unlimited,
          :state => dc[:status]
        )
        res
      end
      datacenters
    end
  end

  def images(credentials, opts = {})
    client = new_client(credentials)
    safely do
      hvs = get_all client, :hypervisors
      images = []
      hvs.each do |hv|
        hv[:templates][:template_details].each do |tpl|
          if opts[:id] and opts[:id] != tpl[:id]
            next
          end
          arch = tpl[:description] !~ /64bit/ ? "i386" : "x86_64"
          images << Image.new(
            :id => tpl[:id],
            :name => tpl[:name],
            :description => tpl[:description],
            :architecture => arch,
            :owner_id => 0,
            :state => "AVAILABLE",
            :hardware_profiles => [InstanceProfile.new(hv[:hypervisor_type])]
          )
        end
      end
      images = filter_on( images, :architecture, opts )
      images = filter_on( images, :owner_id, opts )
      images = filter_on( images, :id, opts )
      images.sort_by{|e| [e.owner_id, e.architecture, e.name, e.description]}
    end
  end

  def instances(credentials, opts={})
    client = new_client(credentials)

    safely do
      if opts[:id]
        instances = [convert_instance(client, opts[:id])]
      else
        instances = get_all(client, :servers).collect do |srv|
          convert_instance(client, srv[:server_id])
        end
      end
      filter_on(instances, :state, opts)
    end
  end

  def create_instance(credentials, image_id, opts={})
    client = new_client(credentials, opts[:realm_id])
    safely do
      ram = opts[:hwp_memory].to_i / 1024
      if not opts[:password] or opts[:password] == ''
        raise "Missing Parameter 'password'"
      end
      params = {
        :server => {
          "arub:AdministratorPassword" => opts[:password].to_s,
          "arub:CPUQuantity" => opts[:hwp_cpu].to_s,
          "arub:Name" => opts[:name],
          "arub:OSTemplateId" => opts[:image_id].to_s,
          "arub:RAMQuantity" => ram.to_s,
          "arub:VirtualDisks" => {
            "arub:VirtualDiskDetails" => {
              "arub:Size" => opts[:hwp_storage]
            }
          }
        }
      }
      # since Aruba API does not return the new server id when calling
      # set_enqueue_server_creation, get the server_id from the job list
      prev_jobs = get_jobs(client, "AddVirtualMachine")
      request(client, :enqueue_server_creation, params, "set")
      jobs = get_jobs(client, "AddVirtualMachine") - prev_jobs
      convert_instance(client, jobs.sort_by {|j| j[:job_id].to_i}.reverse.first[:server_id])
    end
  end

  def start_instance(credentials, id)
    client = new_client(credentials)
    safely do
      request(client, :enqueue_server_start, {:serverId => id}, "set")
      convert_instance client, id
    end
  end

  def stop_instance(credentials, id)
    client = new_client(credentials)
    safely do
      request(client, :enqueue_server_stop, {:serverId => id}, "set")
      convert_instance client, id
    end
  end

  def reboot_instance(credentials, id)
    client = new_client(credentials)
    safely do
      request(client, :enqueue_server_restart, {:serverId => id}, "set")
      convert_instance client, id
    end
  end

  def destroy_instance(credentials, id)
    client = new_client(credentials)
    safely do
      request(client, :enqueue_server_deletion, {:serverId => id}, "set")
      convert_instance client, id
    end
  end

  def configured_providers
    Deltacloud::Drivers::driver_config[:aruba][:entrypoints]["compute"].keys
  end

  def storage_volumes(credentials, opts={})
    client = new_client(credentials)
    safely do
      servers = get_all client, :servers
      volumes = servers.inject([]) do |result, srv|
        instance = convert_instance(client, srv[:server_id])
        details = request client, :server_details, {:serverId => instance.id}
        vdisks = details[:virtual_disks][:virtual_disk]
        vdisks = vdisks.kind_of?(Array) ? vdisks : [vdisks]
        vdisks.each do |vd|
          if instance.state == "STOPPED"
            actions = vd[:resource_type] == "HardDrive0" ? [:snapshot] : [:snapshot, :detach]
          else
            actions = []
          end
          result << StorageVolume.new(
            :id => vd[:resource_id],
            :name => "#{instance.name}-#{vd[:resource_type]}",
            :capacity => vd[:size],
            :instance_id => instance.id,
            :realm_id => instance.realm_id,
            :state => "IN-USE",
            :created => vd[:creation_date],
            :kind => 'data',
            :actions => actions,
            :device => nil
          ) if opts[:id].nil? or opts[:id] == vd[:resource_id]
        end
        result
      end
      volumes
    end
  end

  def addresses(credentials, opts={})
    client = new_client(credentials)
    safely do
      get_all(client, :purchased_ip_addresses, :ip_address).collect do |ip|
          Address.new(:id => ip[:value], :instance_id => ip[:server_id])
      end
    end
  end

  def create_address(credentials, opts={})
    client = new_client(credentials)
    safely do
      ip = request(client, :purchase_ip_address, {}, "set")
      address = Address.new(:id => ip[:value], :instance_id => nil)
    end
  end

  def destroy_address(credentials, opts={})
    client = new_client(credentials)
    safely do
      get_all(client, :purchased_ip_addresses, :ip_address).collect do |ip|
        if ip[:value] == opts[:id]
          request client, :remove_ip_address, {:ipAddressResourceId => ip[:resource_id]}, "set"
          return
        end
      end
      raise "Could not find ip #{opts[:id]}"
    end
  end

  def associate_address(credentials, opts={})
    client = new_client(credentials)
    safely do

      get_all(client, :purchased_ip_addresses, :ip_address).collect do |ip|
        if ip[:value] == opts[:id]
          details = request client, :server_details, {:serverId => opts[:instance_id]}
          params = {
           :ipAddressResourceIds => {"arr:int" => ip[:resource_id]},
           :networkAdapterId => details[:network_adapters][:network_adapter].first[:id]
          }
          request client, :enqueue_associate_ip_address, params, "set"
          return
        end
      end
      raise "Could not find ip #{opts[:id]}"
    end
  end

  def disassociate_address(credentials, opts={})
    client = new_client(credentials)
    safely do
      get_all(client, :purchased_ip_addresses, :ip_address).collect do |ip|
        if ip[:value] == opts[:id]
          details = request client, :server_details, {:serverId => ip[:server_id]}
          params = {
           :ipAddressResourceIds => {"arr:int" => ip[:resource_id]},
           :networkAdapterId => details[:network_adapters][:network_adapter].first[:id]
          }
          request client, :enqueue_deassociate_ip_address, params, "set"
          return
        end
      end
      raise "Could not find ip #{opts[:id]}"
    end
  end

  private

  def new_client(credentials, realm_id=nil)
    safely do
      wsdl = realm_id ? Deltacloud::Drivers::driver_config[:aruba][:entrypoints]["compute"]["dc#{realm_id}"] : endpoint
      client = Savon.client({wsdl: wsdl, log: false})
      client.wsse.credentials credentials.user, credentials.password
      client.request :get_user_authentication_token
      client
    end
  end

  def get_all(client, entity, field = nil)
    method = "get_#{entity}".to_sym
    field = field ? field : entity.to_s.chomp("s").to_sym
    response = client.request method
    result = response.body["#{method}_response".to_sym]["#{method}_result".to_sym][:value][field]
    result = result.nil? ? [] : result.kind_of?(Array) ? result : [result]
    result
  end

  def request(client, entity, params, verb="get")
    meth = verb ? "#{verb}_#{entity}".to_sym : entity.to_sym
    opts = {}
    params.map{ |k, v| opts["tns:#{k}"] = v }
    response = client.request meth do
      soap.namespaces["xmlns:arub"] = "http://schemas.datacontract.org/2004/07/Aruba.Cloud.Provisioning.Entities"
      soap.namespaces["xmlns:arr"] = "http://schemas.microsoft.com/2003/10/Serialization/Arrays"
      soap.body = opts
    end
    data = response.body["#{meth}_response".to_sym]["#{meth}_result".to_sym]
    if not data[:success]
      raise data[:result_message]
    end

    data [:value]
  end

  def get_jobs(client, type)
    get_all(client, :jobs).inject([]) do |res, j|
      if j[:operation_name] == type
        res << j
      end
      res
    end
  end

  def convert_state(state)
    case state
    when "Stopped"
      "STOPPED"
    when "Running"
      "RUNNING"
    when "Creating"
      "PENDING"
    end
  end

  def convert_instance(client, id)
    safely do
      details = request client, :server_details, {:serverId => id}
      ip_addresses = details[:network_adapters][:network_adapter].inject([]) do |result, adp|
        if adp[:ip_addresses]
          if adp[:ip_addresses][:ip_address].kind_of? Array
            result += adp[:ip_addresses][:ip_address].map{ |x|
              InstanceAddress.new(x[:value], :type => :ipv4)
            }
          else
            result << InstanceAddress.new(
              adp[:ip_addresses][:ip_address][:value],
              :type => :ipv4
            )
          end
        end
        result
      end

      storage = details[:virtual_disks][:virtual_disk].kind_of?(Array) ?
        details[:virtual_disks][:virtual_disk].first[:size] :
        details[:virtual_disks][:virtual_disk][:size]
      profile = InstanceProfile.new(details[:hypervisor_type],
                                    :hwp_memory => details[:ram_quantity][:quantity].to_i * 1024,
                                    :hwp_cpu => details[:cpu_quantity][:quantity],
                                    :hwp_storage => storage)

      state = convert_state(details[:server_status])
      key_pairs = details[:parameters][:key_value_pair]
      key_pairs = key_pairs.kind_of?(Array) ? key_pairs : [key_pairs]
      private_addresses = key_pairs.inject([]) do |result, kp|
        result << InstanceAddress.new(kp[:value], :type=> :ipv4) if kp[:key] == "HostIp"
        result
      end

      vdisks = details[:virtual_disks][:virtual_disk]
      vdisks = vdisks.kind_of?(Array) ? vdisks : [vdisks]

      actions = instance_actions_for(state)

      Instance.new(
        :id => id,
        :name => details[:name],
        :state => state,
        :image_id => details[:os_template][:id],
        :owner_id => details[:user_id],
        :actions => actions,
        :launch_time => details[:creation_date],
        :realm_id => details[:datacenter_id],
        :create_image => true,
        :public_addresses => ip_addresses,
        :private_addresses => private_addresses,
        :instance_profile => profile,
        :storage_volumes => vdisks.collect {|vd| {vd[:resource_id] => nil} }
      )
    end
  end

  def endpoint
    endpoint = (api_provider || DEFAULT_DC)
    Deltacloud::Drivers::driver_config[:aruba][:entrypoints]["compute"][endpoint] || endpoint
  end

  exceptions do
    on /InvalidSecurity/ do
      status 401
    end

    on /Could not find/ do
      status 404
    end

    on /SocketError|ProviderError/ do
      status 502
    end

    on /ActionNotSupported|DeserializationFailed|Unknown|Missing Parameter/ do
      status 400
    end

    on /Operation already enqueued/ do
      status 412
    end

    on /Too many Public IP/ do
      status 502
    end

    on /IP address.*is associated/ do
      status 400
    end

  end
end

    end #module Aruba
  end #module Drivers
end #module Deltacloud
