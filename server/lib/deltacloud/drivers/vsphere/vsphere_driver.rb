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

require 'deltacloud/base_driver'
require 'deltacloud/drivers/vsphere/vsphere_client'
require 'rbvmomi'

module Deltacloud::Drivers::VSphere

  MAPPER_STORAGE_ROOT = File::join("/var/tmp", "deltacloud-vsphere-#{ENV["USER"]}")

  class VSphereDriver < Deltacloud::BaseDriver

    include Deltacloud::Drivers::VSphere::Helper

    feature :instances, :user_data
    feature :instances, :user_name

    def hardware_profiles(credentials, opts={})
      vsphere = new_client(credentials)
      safely do
        service = vsphere.serviceInstance.content
        max_memory, max_cpu_cores = 0, 0
        service.rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).each do |dc|
          max_memory += dc.hostFolder.childEntity.first.summary.effectiveMemory
          max_cpu_cores += dc.hostFolder.childEntity.first.summary.numCpuCores
        end
        [Deltacloud::HardwareProfile::new('default') do
          cpu (1..max_cpu_cores)
          memory (128..max_memory)
          architecture ['x86_64', 'i386']
        end]
      end
    end

    # Configure instance state machine
    define_instance_states do
      start.to(:pending)          .on( :create )
      pending.to(:stopped)        .automatically
      stopped.to(:running)        .on( :start )
      running.to(:running)        .on( :reboot )
      running.to(:shutting_down)  .on( :stop )
      shutting_down.to(:stopped)  .automatically
      stopped.to(:finish)         .on( :destroy )
    end


    # List all images, across all datacenters. Note: Deltacloud API does not
    # yet support filtering images by realm.
    def images(credentials, opts=nil)
      cloud = new_client(credentials)
      img_arr = []

      # Skip traversing through all instances in all datacenters when ID
      # attribute is set
      safely do
        if opts[:id]
          template_vms = [ find_vm(credentials, opts[:id]) ].compact
        else
          template_vms = list_virtual_machines(credentials).select { |vm| vm[:instance].summary.config[:template] }
        end
        img_arr = template_vms.collect do |image_hash|
          # Since all calls to vm are threaten as SOAP calls, reduce them using
          # local variable.
          image, realm = image_hash[:instance], image_hash[:datastore]
          config = image.summary.config
          instance_state = convert_state(:instance, image.summary.runtime[:powerState])
          properties = {
            :name => config[:name],
            :full_name => config[:guestFullName]
          }
          image_state = convert_state(:image, image.summary.runtime[:powerState])
          image_architecture = extract_architecture(properties[:full_name]) || 'x86_64'
          Image.new(
            :id => properties[:name],
            :name => properties[:name],
            :architecture => image_architecture,
            :owner_id => credentials.user,
            :description => properties[:full_name],
            :state => image_state
          )
        end
      end
      img_arr = filter_on( img_arr, :architecture, opts )
      img_arr.sort_by{|e| [e.owner_id, e.name]}
    end

    def create_image(credentials, opts={})
      vsphere = new_client(credentials)
      safely do
        find_vm(credentials, opts[:id])[:instance].MarkAsTemplate
      end
      images(credentials, :id => opts[:id])
    end

    # List all datacenters managed by the vSphere or vCenter entrypoint.
    def realms(credentials, opts=nil)
      vsphere = new_client(credentials)
      safely do
        if opts and opts[:id]
          datastore = find_datastore(credentials, opts[:id])
          [convert_realm(datastore)]
        else
          rootFolder = vsphere.serviceInstance.content.rootFolder
          rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).collect do |dc|
            dc.datastoreFolder.childEntity.collect { |datastore| convert_realm(datastore) }
          end.flatten
        end
      end
    end

    # List all running instances, across all datacenters. DeltaCloud API does
    # not yet support filtering instances by realm.
    def instances(credentials, opts=nil)
      cloud = new_client(credentials)
      inst_arr, machine_vms, stored_vms = [], [], []
      safely do
        if opts[:id]
          machine_vms = [ find_vm(credentials, opts[:id]) ].compact
        else
          machine_vms = list_virtual_machines(credentials).select { |vm| !vm[:instance].summary.config[:template] }
        end
        stored_tasks(cloud) do |task|
          if task.info.entity.class == RbVmomi::VIM::VirtualMachine and ['queued', 'running'].member? task.info.state
            stored_vms << load_serialized_instance(task.info.key)
          end
        end
      end
      safely do
        inst_arr = machine_vms.collect do |vm_hash|
          # Since all calls to vm are threaten as SOAP calls, reduce them using
          # local variable.
          vm, realm_id = vm_hash[:instance], vm_hash[:datastore]
          config = vm.summary.config
          next if not config
          template_id = vm.config[:extraConfig].select { |k| k.key == 'template_id' }
          template_id = template_id.first.value unless template_id.empty?
          properties = {
            :memory => config[:memorySizeMB],
            :cpus => config[:numCpu],
            :storage => vm.summary.storage[:unshared],
            :name => config[:name],
            :full_name => config[:guestFullName],
          }
          instance_state = convert_state(:instance, vm.summary.runtime[:powerState])
          instance_profile = InstanceProfile::new('default',
                                                  :hwp_cpu => properties[:cpus],
                                                  :hwp_memory => properties[:memory],
                                                  :hwp_storage => properties[:storage])
          instance_address = vm.guest[:net].empty? ? vm.macs.values.first : vm.guest[:net].first[:ipAddress].first
          Instance.new(
            :id => properties[:name],
            :name => properties[:name],
            :owner_id => credentials.user,
            :image_id => template_id,
            :description => properties[:full_name],
            :realm_id => realm_id,
            :state => instance_state,
            :public_addresses => instance_address,
            :private_addresses => [],
            :instance_profile => instance_profile,
            :actions => instance_actions_for( instance_state ),
            :create_image => true
          )
        end
      end

      # Append 'PENDING' instances
      inst_arr += stored_vms
      inst_arr.compact!
      filter_on( inst_arr, :state, opts )
    end


    def create_instance(credentials, image_id, opts)
      vsphere = new_client(credentials)
      safely do
        rootFolder = vsphere.serviceInstance.content.rootFolder
        vm = find_vm(credentials, opts[:image_id])
        # Find correct ResourcePool and Datastore where a new VM will be
        # located
        if opts and opts[:realm_id]
          resourcePool = find_resource_pool(credentials, opts[:realm_id])
          datastore = find_datastore(credentials, opts[:realm_id])
        else
          resourcePool = find_resource_pool(credentials, vm[:datastore])
          datastore = find_datastore(credentials, opts[:datastore])
        end
        relocate = { :pool => resourcePool, :datastore => datastore }
        relocateSpec = RbVmomi::VIM.VirtualMachineRelocateSpec(relocate)
        # Set extra configuration for VM, like template_id
        machine_config = {
          :memoryMB => opts[:hwp_memory],
          :numCPUs => opts[:hwp_cpu],
          :extraConfig => [
            { :key => 'template_id', :value => image_id },
          ]
        }
        # If user wants to inject data into instance he need to submit a Base64
        # encoded gzipped ISO image.
        # This image will be uplaoded to the Datastore given in 'realm_id'
        # parameter and them attached to instance.
        if opts[:user_data] and not opts[:user_data].empty?
          device = vm[:instance].config.hardware.device.select { |hw| hw.class == RbVmomi::VIM::VirtualCdrom }.first
          if device
            # TODO: Upload baked ISO image to the Datastore
            machine_config[:extraConfig] << {
              :key => 'user_data_file', :value => "#{opts[:name]}.iso"
            }
            device.backing = RbVmomi::VIM.VirtualCdromIsoBackingInfo(:fileName => "[#{opts[:realm_id] || vm[:datastore]}] #{opts[:name].iso}")
            machine_config.merge!({
              :deviceChange => [{
                :operation => :edit,
                :device => device
              }]
            })
          else
            raise "Failed to inject data to device because there is no CD-ROM drive defined in given template"
          end
        end
        spec = RbVmomi::VIM.VirtualMachineCloneSpec(
          :location => relocateSpec,
          :powerOn => true,
          :template => false,
          :config => RbVmomi::VIM.VirtualMachineConfigSpec(machine_config)
        )
        instance_profile = InstanceProfile::new('default', :hwp_memory => opts[:hwp_memory], :hwp_cpu => opts[:hwp_cpu])
        task = vm[:instance].CloneVM_Task(:folder => vm[:instance].parent, :name => opts[:name], :spec => spec)
        new_instance = Instance::new(
          :id => opts[:name],
          :name => opts[:name],
          :description => opts[:name],
          :owner_id => credentials.user,
          :image_id => opts[:image_id],
          :realm_id => opts[:realm_id] || vm[:datastore],
          :state => 'PENDING',
          :public_addresses => [],
          :private_addresses => [],
          :instance_profile => instance_profile,
          :actions => instance_actions_for( 'PENDING' ),
          :create_image => false
        )
        map_task_to_instance(task.info.key, new_instance)
      end
    end

    # Reboot an instance, given its id.
    def reboot_instance(credentials, id)
      find_vm(credentials, id)[:instance].ResetVM_Task
    end

    # Start an instance, given its id.
    def start_instance(credentials, id)
      find_vm(credentials, id)[:instance].PowerOnVM_Task
    end

    # Stop an instance, given its id.
    def stop_instance(credentials, id)
      find_vm(credentials, id)[:instance].PowerOffVM_Task
    end

    # Destroy an instance, given its id. Note that this will destory all
    # instance data.
    def destroy_instance(credentials, instance_id)
      find_vm(credentials, instance_id)[:instance].Destroy_Task.wait_for_completion
    end

    alias :destroy_image :destroy_instance

    exceptions do

      on /InvalidLogin/ do
        status 401
      end

      on /RbVmomi::Fault/ do
        status 502
      end

      on /Failed to inject data/ do
        status 502
      end

    end

    def valid_credentials?(credentials)
      begin
        RbVmomi::VIM.connect(:host => host_endpoint, :user => credentials.user, :password => credentials.password, :insecure => true)
        return true
      rescue
        return false
      end
    end

    #######
    private
    #######

    def new_client(credentials)
      safely do
        RbVmomi::VIM.connect(:host => host_endpoint, :user => credentials.user, :password => credentials.password, :insecure => true)
      end
    end

    def host_endpoint
      endpoint = api_provider
      endpoint || Deltacloud::Drivers::driver_config[:vsphere][:entrypoints]['default']['default']
    end

    def convert_realm(datastore)
      Realm::new(
        :id => datastore.name,
        :name => datastore.name, 
        :limit => datastore.summary.freeSpace,
        :state => datastore.summary.accessible ? 'AVAILABLE' : 'UNAVAILABLE'
      )
    end

    def convert_state(object, state)
      new_state = ''
      if object == :image
        new_state = case state
          when 'poweredOff' then 'AVAILABLE'
          when 'poweredOn' then 'UNAVAILABLE'
        end
      end
      if object == :instance
        new_state = case state
          when 'poweredOff' then 'STOPPED'
          when 'poweredOn' then 'RUNNING'
          else 'PENDING'
        end
      end
      new_state
    end

  end

end
