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
require 'rbovirt'

module Deltacloud
  module Drivers
    module RHEVM

class RHEVMDriver < Deltacloud::BaseDriver

  def supported_collections
    DEFAULT_COLLECTIONS - [:storage_snapshots]
  end

  feature :instances, :user_name do
    constraint :max_length, 50
  end

  feature :instances, :user_data

  USER_NAME_MAX = feature(:instances, :user_name).constraints[:max_length]

  # FIXME: These values are just for ilustration
  # Also I choosed 'SERVER' and 'DESKTOP' names
  # because they are referred by VM (API type)
  #
  # Values like RAM or STORAGE are reported by VM
  # so they are not static.

  define_hardware_profile 'SERVER' do
    cpu         ( 1..16 )
    memory      ( 512 .. 32*1024 )
    storage     ( 1 .. 100*1024 )
    architecture 'x86_64'
  end

  define_hardware_profile 'DESKTOP' do
    cpu         ( 1..16 )
    memory      ( 512 .. 32*1024 )
    storage     ( 1 .. 100*1024 )
    architecture 'x86_64'
  end

  define_instance_states do
    start.to( :pending )          .automatically
    pending.to( :stopped )        .automatically
    stopped.to( :running )        .on( :start )
    running.to( :stopping )       .on( :stop )
    stopped.to( :finish )         .on( :destroy )
  end

  def providers(credentials)
    client = new_client(credentials)
    safely do
      client.datacenters.collect { |dc| convert_provider(dc) }
    end
  end

  #
  # Realms
  #

  def realms(credentials, opts={})
    client = new_client(credentials)
    realm_arr = []
    safely do
      realm_arr = client.clusters.collect do |r|
        convert_realm(r, client.datacenter(r.datacenter.id))
      end
    end
    realm_arr = filter_on( realm_arr, :id, opts )
    realm_arr
  end

  def images(credentials, opts={})
    client = new_client(credentials)
    img_arr = []
    safely do
      if (!opts.nil? && opts[:id])
        img_arr << convert_image(client, client.template(opts[:id]))
      else
        img_arr = client.templates.collect { |t| convert_image(client, t) }
      end
    end
    img_arr = filter_on( img_arr, :architecture, opts )
    img_arr.sort_by{|e| [e.owner_id, e.name]}
  end

  def create_image(credentials, opts={})
    client = new_client(credentials)
    unless opts[:name]
      instance = instances(credentials, :id => opts[:id])
      raise "Specified instance '#{opts[:id]}' not found"
      template_name = "#{instance.first.name}-template"
    end
    safely do
      new_image = client.create_template(opts[:id], :name => (opts[:name] || template_name),
                                         :description => opts[:description])
      convert_image(client, new_image)
    end
  end

  def destroy_image(credentials, image_id)
    client = new_client(credentials)
    safely do
      unless client.destroy_template(image_id)
        raise "ERROR: Unable to remove image"
      end
    end
  end

  def instances(credentials, opts={})
    client = new_client(credentials)
    inst_arr = []
    safely do
      if opts[:id]
        vms = client.vms(:id => opts[:id])
      else
        vms = client.vms
      end
      vms.each do |vm|
        inst_arr << convert_instance(client, vm)
      end
    end
    inst_arr = filter_on( inst_arr, :id, opts )
    filter_on( inst_arr, :state, opts )
  end

  def start_instance(credentials, id)
    client = new_client(credentials)
    safely do
      raise "ERROR: Operation start failed" unless client.vm_action(id, :start)
    end
  end

  def stop_instance(credentials, id)
    client = new_client(credentials)
    safely do
      raise "ERROR: Operation start failed" unless client.vm_action(id, :shutdown)
    end
  end

  def destroy_instance(credentials, id)
    client = new_client(credentials)
    safely do
      raise "ERROR: Operation start failed" unless client.destroy_vm(id)
    end
  end

  def storage_volumes(credentials, opts={})
    client = new_client(credentials)
    domains_arr = []
    safely do
      client.storagedomains.each do |s|
        domains_arr << convert_volume(s)
      end
    end
    domains_arr = filter_on( domains_arr, :id, opts )
    filter_on( domains_arr, :state, opts )
  end

  def create_instance(credentials, image_id, opts={})
    client = new_client(credentials)
    params = {}
    if opts[:name]
      raise "Parameter name must be #{USER_NAME_MAX} characters or less" if opts[:name].length > USER_NAME_MAX
    end
    safely do
      params[:name] = opts[:name]
      params[:template] = opts[:image_id]
      params[:cluster] = opts[:realm_id] if opts[:realm_id]
      params[:hwp_id] = opts[:hwp_id] if opts[:hwp_id]
      params[:memory] = (opts[:hwp_memory].to_i * 1024 * 1024) if opts[:hwp_memory]
      params[:cores] = opts[:hwp_cpu] if opts[:hwp_cpu]
      params[:user_data] = opts[:user_data].gsub(/\n/,'') if opts[:user_data]
      convert_instance(client, client.create_vm(params))
    end
  end

  def valid_credentials?(credentials)
    begin
      realms(credentials) && true
    rescue RestClient::Unauthorized
      retval = false
    rescue => e
      safely do
        raise e
      end
    end
  end

  private

  def new_client(credentials)
    url, datacenter = api_provider.split(';')
    safely do
      OVIRT::Client.new(credentials.user, credentials.password, url, datacenter)
    end
  end

  def convert_provider(dc)
    Provider.new(
      :id => dc.id,
      :name => dc.name,
      :url => [api_provider.split(';').first, dc.id].join(';')
    )
  end

  def confserver_ip(uuid)
    client = RestClient::Resource::new(ENV['CONFIG_SERVER_ADDRESS'])
    client["/ip/%s/%s" % [ (ENV['CONFIG_SERVER_VERSION'] || '0.0.1'), uuid]].get(:accept => 'text/plain').body.strip rescue nil
  end

  def convert_instance(client, inst)
    state = convert_state(inst.status)
    storage_size = inst.storage.nil? ? 1 :  (inst.storage.to_i/1024/1024/1024)
    profile = InstanceProfile::new(inst.profile.upcase,
                                   :hwp_memory => inst.memory.to_i/1024/1024,
                                   :hwp_cpu => inst.cores,
                                   :hwp_storage => "#{storage_size}"
    )

    # First try to get IP address from RHEV-M. This require rhev-agent package
    # installed on guest
    public_addresses = inst.ips.map { |ip| InstanceAddress.new(ip, :type => :ipv4) }

    # ConfServer will overide the IP address returned by RHEV-M guest agent
    if ENV['CONFIG_SERVER_ADDRESS']
      ip = confserver_ip(inst.id)
      public_addresses = [ InstanceAddress.new(ip) ]
    end
    # If IP retrieval failed, fallback to VNC and MAC address
    if public_addresses.empty?
      public_addresses = inst.interfaces.map { |interface| InstanceAddress.new(interface.mac, :type => :mac) }
    end
    if inst.vnc
      public_addresses << InstanceAddress.new(inst.vnc[:address], :port => inst.vnc[:port], :type => :vnc)
    end
    Instance.new(
      :id => inst.id,
      :name => inst.name,
      :state => state,
      :image_id => inst.template.id,
      :realm_id => inst.cluster.id,
      :owner_id => client.credentials[:username],
      :launch_time => inst.creation_time,
      :instance_profile => profile,
      :hardware_profile_id => profile.id,
      :actions=>instance_actions_for( state ),
      :public_addresses => public_addresses,
      :private_addresses => [],
      :create_image => true
    )
  end

  # STATES:
  #
  # UNASSIGNED, DOWN, UP, POWERING_UP, POWERED_DOWN, PAUSED, MIGRATING_FROM,
  # MIGRATING_TO, UNKNOWN, NOT_RESPONDING, WAIT_FOR_LAUNCH, REBOOT_IN_PROGRESS,
  # SAVING_STATE, RESTORING_STATE, SUSPENDED, IMAGE_ILLEGAL,
  # IMAGE_LOCKED or POWERING_DOWN
  #
  def convert_state(state)
    unless state.respond_to?(:upcase)
      raise "State #{state.inspect} is not a string"
    end
    case state.strip.upcase
    when 'WAIT_FOR_LAUNCH', 'REBOOT_IN_PROGRESS', 'SAVING_STATE',
      'RESTORING_STATE', 'POWERING_UP', 'IMAGE_LOCKED', 'SAVING_STATE' then
      'PENDING'
    when 'POWERING_DOWN' then
      'STOPPING'
    when 'UNASSIGNED', 'DOWN', 'PAUSED', 'NOT_RESPONDING', 'SUSPENDED', 'IMAGE_ILLEGAL', 'UNKNOWN' then
      'STOPPED'
    when 'UP', 'MIGRATING_TO', 'MIGRATING_FROM'
      'RUNNING'
    else
      raise "Unexpected state '#{state}'"
    end
  end

  def convert_volume(volume)
    StorageVolume.new(
      :id => volume.id,
      :state => 'AVAILABLE',
      :capacity => ((volume.available.to_i-volume.used.to_i)/1024/1024/1024).abs,
      :instance_id => nil,
      :kind => volume.kind,
      :name => volume.name,
      :device => volume.address ? "#{volume.address}:#{volume.path}" : nil
    )
  end

  def convert_image(client, img)
    Image.new(
      :id => img.id,
      :name => img.name,
      :description => img.description,
      :owner_id => client.credentials[:username],
      :architecture => 'x86_64', # All RHEV-M VMs are x86_64
      :hardware_profiles => hardware_profiles(nil),
      :state => img.status
    )
  end

  def convert_realm(r, dc)
    Realm.new(
      :id => r.id,
      :name => r.name,
      :state => dc.status.strip.upcase == 'UP' ? 'AVAILABLE' : 'DOWN',
      :limit => :unlimited
    )
  end

  exceptions do

    on /Bad Request/ do
      status 400
    end

    on /RestClient::Unauthorized/ do
      status 401
    end

    on /RestClient::ResourceNotFound/ do
      status 404
    end

    on /RestClient::InternalServerError/ do
      status 502
    end

    on /(RestClient|RHEVM)/ do
      status 500
    end

    on /(.*) not found^/ do
      status 400
    end

    on /Parameter name/ do
      status 400
    end

  end

end

    end
  end
end
