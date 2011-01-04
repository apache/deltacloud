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

# Minihowto: Setting up this driver
#
# 1. Setup RHEV-M server
# 2. Setup RHEV-M API (git://git.fedorahosted.org/rhevm-api.git - follow README)
# 3. Set URL to API using shell variable (or HTTP header, see comment on provider_url)
#    export API_PROVIDER="https://x.x.x.x/rhevm-api-powershell"
# 4. Start Deltacloud using: deltacloudd -i rhevm
# 5. Use RHEV-M credentials + append Windows Domain
#    like: admin@rhevm.example.com

require 'deltacloud/base_driver'
require 'deltacloud/drivers/rhevm/rhevm_client'

module Deltacloud
  module Drivers
    module RHEVM

class RHEVMDriver < Deltacloud::BaseDriver

  feature :instances, :user_name

  # FIXME: These values are just for ilustration
  # Also I choosed 'SERVER' and 'DESKTOP' names
  # because they are referred by VM (API type)
  #
  # Values like RAM or STORAGE are reported by VM
  # so they are not static.

  define_hardware_profile 'SERVER' do
    cpu         ( 1..4 )
    memory      ( 512 .. 32*1024 )
    storage     ( 1 .. 100*1024 )
    architecture 'x86_64'
  end

  define_hardware_profile 'DESKTOP' do
    cpu         ( 1..4 )
    memory      ( 512 .. 32*1024 )
    storage     ( 1 .. 100*1024 )
    architecture 'x86_64'
  end

  # Instead of setting a URL for RHEV provider
  # do it here in driver, so it can be altered by HTTP headers
  #
  def provider_uri=(uri)
    @RHEVM_URI = uri
  end

  # Default Provider URI.
  #
  # IMPORTANT:
  # This URI can be overridden using shell variable API_PROVIDER
  # or setting provider using HTTP header X-Deltacloud-Provider to URL.
  #
  def provider_uri
    'https://10.34.2.122:8443/rhevm-api-powershell'
  end

  define_instance_states do
    start.to( :pending )          .automatically
    pending.to( :running )        .automatically
    pending.to( :stopped )        .automatically
    pending.to( :finish )         .on(:destroy)
    stopped.to( :running )        .on( :start )
    stopped.to( :finish )         .on( :destroy )
    running.to( :running )        .on( :reboot )
    running.to( :stopping )       .on( :stop )
    shutting_down.to( :stopped )  .automatically
    stopped.to( :finish )         .automatically
  end

  #
  # Realms
  #

  def realms(credentials, opts=nil)
    client = new_client(credentials)
    realm_arr = []
    safely do
      clusters = client.clusters
      clusters.each do |r|
        d = client.datacenters(:id => r.datacenter_id)
        realm_arr << convert_realm(r, d)
      end
    end
    realm_arr
  end

  def images(credentials, opts={})
    client = new_client(credentials)
    img_arr = []
    safely do
      templates = client.templates
      if (!opts.nil? && opts[:id])
        templates = templates.select{|t| opts[:id] == t.id}
      end
      templates.each do |t|
        img_arr << convert_image(client, t)
      end
    end
    img_arr = filter_on( img_arr, :architecture, opts )
    img_arr.sort_by{|e| [e.owner_id, e.name]}
  end

  def instances(credentials, opts={})
    client = new_client(credentials)
    inst_arr = []
    safely do
      vms = client.vms
      vms.each do |vm|
        inst_arr << convert_instance(client, vm)
      end
    end
    inst_arr = filter_on( inst_arr, :id, opts )
    filter_on( inst_arr, :state, opts )
  end

  def reboot_instance(credentials, id)
    client = new_client(credentials)
    safely do
      client.vm_action(:reboot, id)
    end
  end

  def start_instance(credentials, id)
    client = new_client(credentials)
    safely do
      client.vm_action(:start, id)
    end
  end

  def stop_instance(credentials, id)
    client = new_client(credentials)
    safely do
      client.vm_action(:suspend, id)
    end
  end

  def destroy_instance(credentials, id)
    client = new_client(credentials)
    safely do
      client.delete_vm(id)
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
    safely do
      # TODO: Add setting CPU topology here
      vm_name = opts[:name] ? "<name>#{opts[:name]}</name>" : ""
      vm_template = "<template id='#{image_id}'/>"
      vm_cluster = opts[:realm_id] ? "<cluster id='#{opts[:realm_id]}'/>" : "<cluster id='0'/>"
      vm_type = opts[:hwp_id] ? "<type>#{opts[:hwp_id]}</type>" : "<type>DESKTOP</type>"
      vm_memory = opts[:hwp_memory] ? "<memory>#{opts[:hwp_memory].to_i*1024*1024}</memory>"  : ''
      vm_cpus = opts[:hwp_cpu] ? "<cpu><topology cores='#{opts[:hwp_cpu]}' sockets='1'/></cpu>"  : ''
      puts vm_cpus.inspect
      # TODO: Add storage here (it isn't supported by RHEV-M API so far)
      convert_instance(client, ::RHEVM::Vm::new(client, client.create_vm(
        "<vm>"+
        vm_name +
        vm_template +
        vm_cluster +
        vm_type +
        vm_memory +
        vm_cpus +
        "</vm>"
      ).xpath('vm')))
    end
  end

  private

  def new_client(credentials)
    url = (Thread.current[:provider] || ENV['API_PROVIDER'] || provider_uri)
    ::RHEVM::Client.new(credentials.user, credentials.password, url)
  end

  def convert_instance(client, inst)
    state = convert_state(inst.status)
    storage_size = inst.storage.nil? ? 1 :  (inst.storage/1024/1024)
    profile = InstanceProfile::new(inst.profile, 
                                   :hwp_memory => inst.memory/1024,
                                   :hwp_cpu => inst.cores,
                                   :hwp_storage => "#{storage_size}"
    )
    # TODO: Implement public_addresses (nics/ip)
    # NOTE: This must be enabled on 'guest' side, otherwise this property is not
    # available through RHEV-M API
    Instance.new(
      :id => inst.id,
      :name => inst.name,
      :state => state,
      :image_id => inst.template,
      :realm_id => inst.cluster,
      :owner_id => client.username,
      :launch_time => inst.creation_time,
      :instance_profile => profile,
      :hardware_profile_id => profile.id,
      :actions=>instance_actions_for( state )
    )
  end

  # STATES: 
  #
  # UNASSIGNED, DOWN, UP, POWERING_UP, POWERED_DOWN, PAUSED, MIGRATING_FROM, MIGRATING_TO, 
  # UNKNOWN, NOT_RESPONDING, WAIT_FOR_LAUNCH, REBOOT_IN_PROGRESS, SAVING_STATE, RESTORING_STATE, 
  # SUSPENDED, IMAGE_ILLEGAL, IMAGE_LOCKED or POWERING_DOWN 
  #
  def convert_state(state)
    case state
    when 'WAIT_FOR_LAUNCH', 'REBOOT_IN_PROGRESS', 'SAVING_STATE',
      'RESTORING_STATE', 'POWERING_DOWN' then
      'PENDING'
    when 'UNASSIGNED', 'DOWN', 'POWERING_DOWN', 'PAUSED', 'NOT_RESPONDING', 'SAVING_STATE', 
      'SUSPENDED', 'IMAGE_ILLEGAL', 'IMAGE_LOCKED', 'UNKNOWN' then
      'STOPPED'
    when 'POWERING_UP', 'UP', 'MIGRATING_TO', 'MIGRATING_FROM'
      'RUNNING'
    end
  end

  def convert_volume(volume)
    StorageVolume.new(
      :id => volume.id,
      :state => 'AVAILABLE',
      :capacity => ((volume.available-volume.used)/1024/1024).abs,
      :instance_id => nil,
      :kind => volume.kind,
      :name => volume.name,
      :device => "#{volume.storage_address}:#{volume.storage_path}"
    )
  end

  def convert_image(client, img)
    Image.new(
      :id => img.id,
      :name => img.name,
      :description => img.description,
      :owner_id => client.username,
      :architecture => 'x86_64', # All RHEV-M VMs are x86_64
      :status => img.status
    )
  end

  def convert_realm(r, dc)
    Realm.new(
      :id => r.id,
      :name => dc.name,
      :state => dc.status == 'UP' ? 'AVAILABLE' : 'DOWN',
      :limit => :unlimited
    )
  end

  # Disabling this error catching will lead to more verbose messages
  # on console (eg. response from RHEV-M API (so far I didn't figure our
  # how to pass those message to our exception handling tool)
  #def catched_exceptions_list
  #  {
  #    :auth => RestClient::Unauthorized,
  #    :error => RestClient::InternalServerError,
  #    :glob => [ /RestClient::(\w+)/ ]
  #  }
  #end

end

    end
  end
end
