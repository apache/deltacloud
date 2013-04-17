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

  DEFAULT_REGION = 'dc1'

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

  def images(credentials, opts={})
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

      if not opts[:password] or opts[:password] == ''
        raise "Missing parameter 'password' for Administrative Password"
      end

      if not opts[:image_id] or opts[:image_id] == ''
        raise "Missing parameter 'image_id' for Image Template"
      end

      if not opts[:name] or opts[:name] == ''
        o =  [('a'..'z')].map{|i| i.to_a}.flatten
        name  = "Delta14-" + (0...8).map{ o[rand(o.length)] }.join
      else
        name = opts[:name]
      end

      image_info = get_image_info(client, opts[:image_id].to_s)

      limits = {}

      image_info[:resource_bounds].each do |k, bounds|
        bounds.each do |bound|
          if limits.has_key?(bound[:resource_type])
            next
          end

          limits[bound[:resource_type]] = {
            "default" => bound[:default],
            "min" => bound[:min],
            "max" => bound[:max]
          }
        end
      end
      
      # test fro image and hypervisor consistency
      if opts[:hwp_id] and opts[:hwp_id] != image_info[:hw]
        raise "Chosen image is not consistent with chosen Hardware Profile (hwp_id)"
      end

      ram = opts[:hwp_memory] ? opts[:hwp_memory].to_i / 1024 : limits["Ram"]["default"].to_i
      cpu = opts[:hwp_cpu] ? opts[:hwp_cpu].to_i : limits["Cpu"]["default"].to_i
      disk0 = opts[:hwp_storage] ? opts[:hwp_storage].to_i : limits["HardDisk0"]["default"].to_i

      # Check min/max
      ram = ram < limits["Ram"]["min"].to_i ? limits["Ram"]["min"].to_i : (ram > limits["Ram"]["max"].to_i ? limits["Ram"]["max"].to_i : ram)
      cpu = cpu < limits["Cpu"]["min"].to_i ? limits["Cpu"]["min"].to_i : (cpu > limits["Cpu"]["max"].to_i ? limits["Cpu"]["max"].to_i : cpu)
      disk0 = disk0 < limits["HardDisk0"]["min"].to_i ? limits["HardDisk0"]["min"].to_i : (disk0 > limits["HardDisk0"]["max"].to_i ? limits["HardDisk0"]["max"].to_i : disk0)

      #disk must be multiple of 10
      if disk0 % 10 != 0
        disk0 = (disk0 / 10 + 1) * 10
      end
      
      params = {
        :server => {
          "arub:AdministratorPassword" => opts[:password].to_s,
          "arub:CPUQuantity" => cpu.to_s,          
          "arub:Name" => name,
          "arub:OSTemplateId" => opts[:image_id].to_s,        
          "arub:RAMQuantity" => ram.to_s,
          "arub:VirtualDisks" => {
            "arub:VirtualDiskDetails" => {
              "arub:Size" => disk0.to_s
            }
          }
        }
      }
      # since Aruba API does not return the new server id when calling
      # set_enqueue_server_creation, get the server_id from the job list
      prev_jobs = get_jobs(client, "AddVirtualMachine")
      res = request(client, :enqueue_server_creation, params, "set")
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
    Deltacloud::Drivers::driver_config[:arubacloud][:entrypoints]["compute"].keys
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

  def new_client(credentials, realm_id=nil, log_request=false)
    safely do
      wsdl = realm_id ? Deltacloud::Drivers::driver_config[:arubacloud][:entrypoints]["compute"]["dc#{realm_id}"] : endpoint
      namespaces = {
        "xmlns:arub" => "http://schemas.datacontract.org/2004/07/Aruba.Cloud.Provisioning.Entities",
        "xmlns:arr" => "http://schemas.microsoft.com/2003/10/Serialization/Arrays"
      }
      client = Savon.client({wsdl: wsdl, log: log_request, namespaces:namespaces, 
                             wsse_auth: [credentials.user, credentials.password]})
      client.call(:get_user_authentication_token)
      client
    end
  end

  def get_jobs(client, type)
    get_all(client, :jobs).inject([]) do |res, j|
      if j[:operation_name] == type
        res << j
      end
      res
    end
  end

  def get_all(client, entity, field = nil)
    method = "get_#{entity}".to_sym
    field = field ? field : entity.to_s.chomp("s").to_sym
    response = client.call method
    result = response.body["#{method}_response".to_sym]["#{method}_result".to_sym][:value][field]
    result = result.nil? ? [] : result.kind_of?(Array) ? result : [result]
    result
  end

  def get_image_info(client, image_id)
    hvs = get_all client, :hypervisors
    hvs.each do |hv|
      hv[:templates][:template_details].each do |tpl|
        if image_id != tpl[:id]
          next
        end

        tpl[:hw] = hv[:hypervisor_type]
        
        return tpl

      end
    end
  end

  def request(client, entity, params, verb="get")
    meth = verb ? "#{verb}_#{entity}".to_sym : entity.to_sym
    opts = {}
    params.map{ |k, v| opts["tns:#{k}"] = v }
    response = client.call(meth, message: opts)
    data = response.body["#{meth}_response".to_sym]["#{meth}_result".to_sym]
    if not data[:success]
      raise "Error from remote Backend: " + data[:result_message]
    end
    data [:value]
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
    endpoint = (api_provider || DEFAULT_REGION)
    Deltacloud::Drivers::driver_config[:arubacloud][:entrypoints]["compute"][endpoint] || endpoint
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
