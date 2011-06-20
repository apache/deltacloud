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
require 'rbvmomi'

module Deltacloud::Drivers::VSphere

  class VSphereDriver < Deltacloud::BaseDriver

    # Set of predefined hardware profiles
    define_hardware_profile('small') do
      cpu                1
      memory             256
      architecture       'x86_64'
    end

    define_hardware_profile('medium') do
      cpu                1
      memory             512
      architecture       'x86_64'
    end

    define_hardware_profile('large') do
      cpu                2
      memory             1024
      architecture       'x86_64'
    end

    define_hardware_profile('x-large') do
      cpu                4
      memory             2048
      architecture       'x86_64'
    end

    # Since user can launch own instance using vSphere tools 
    # with customized properties, threat this hardware profile as
    # unknown
    define_hardware_profile('unknown') do
      # NOTE: Memory and CPU should be set properly
      architecture       'x86_64'
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
          template_vms = list_virtual_machines(credentials).select { |vm| vm.summary.config[:template] }
        end

        img_arr = template_vms.collect do |image|
          # Since all calls to vm are threaten as SOAP calls, reduce them using
          # local variable.
          config = image.summary.config
          instance_state = convert_state(:instance, image.summary.runtime[:powerState])
          properties = {
            :name => config[:name],
            :full_name => config[:guestFullName]
          }
          image_state = convert_state(:image, image.summary.runtime[:powerState])
          Image.new(
            :id => properties[:name],
            :name => properties[:name],
            :architecture => 'x86_64',  # FIXME: I'm not sure if all templates/VM's in vSphere are x86_64
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
        find_vm(credentials, opts[:id]).MarkAsTemplate
      end
      image(credentials, :id => opts[:id])
    end

    # List all datacenters managed by the vSphere or vCenter entrypoint.
    def realms(credentials, opts=nil)
      vsphere = new_client(credentials)
      safely do
        rootFolder = vsphere.serviceInstance.content.rootFolder
        rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).collect do |dc|
          Realm.new(
            :id => dc.name,
            :name => dc.name, 
            :limit => :unlimited,
            :state => convert_state(:datacenter, dc.configStatus)
          )
        end
      end
    end

    # List all running instances, across all datacenters. DeltaCloud API does
    # not yet support filtering instances by realm.
    def instances(credentials, opts=nil)
      cloud = new_client(credentials)
      inst_arr, machine_vms = [], []
      safely do
        if opts[:id]
          machine_vms = [ find_vm(credentials, opts[:id]) ].compact
        else
          machine_vms = list_virtual_machines(credentials).select { |vm| !vm.summary.config[:template] }
        end
      end
      realm_id = realms(credentials).first.id
      safely do
        inst_arr = machine_vms.collect do |vm|
          # Since all calls to vm are threaten as SOAP calls, reduce them using
          # local variable.
          config = vm.summary.config
          next unless config
          next unless vm.summary.storage
          properties = {
            :memory => config[:memorySizeMB],
            :cpus => config[:numCpu],
            :storage => vm.summary.storage[:unshared],
            :name => config[:name],
            :full_name => config[:guestFullName]
          }
          instance_state = convert_state(:instance, vm.summary.runtime[:powerState])
          instance_profile = InstanceProfile::new(match_hwp_id(:memory => properties[:memory].to_s, :cpus => properties[:cpus].to_s),
                                                  :hwp_cpu => properties[:cpus],
                                                  :hwp_memory => properties[:memory],
                                                  :hwp_storage => properties[:storage])
          instance_address = vm.guest[:net].empty? ? vm.macs.values.first : vm.guest[:net].first[:ipAddress].first
          Instance.new(
            :id => properties[:name],
            :name => properties[:name],
            :owner_id => credentials.user,
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
      filter_on( inst_arr, :state, opts )
    end


    def create_instance(credentials, image_id, opts)
      vsphere = new_client(credentials)
      safely do
        rootFolder = vsphere.serviceInstance.content.rootFolder
        # FIXME: This will consume first datacenter and ignore 'realm' property
        dc = rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).collect.first
        vm = dc.find_vm(image_id)
        resource_pool = dc.hostFolder.childEntity.collect.first.resourcePool
        relocateSpec = RbVmomi::VIM.VirtualMachineRelocateSpec(:pool => resource_pool)
        # NOTE: 'powerOn' attribute will force machine to start after clone operation
        #       'template' attribute will mark VM as a template if set to true
        spec = RbVmomi::VIM.VirtualMachineCloneSpec(
          :location => relocateSpec,
          :powerOn => true,
          :template => false,
          :config => RbVmomi::VIM.VirtualMachineConfigSpec(
            :memoryMB => 256,
            :numCPUs => 1
          )
        )
        # NOTE: This operation may take a very long time (about 1m) to complete
        puts "Cloning template #{image_id} to #{opts[:name]}..."
        vm.CloneVM_Task(:folder => vm.parent, :name => opts[:name], :spec => spec).wait_for_completion
        puts "Cloning complete!"
        # Since task itself is not returning anything, construct Instance from things we already have
        Instance::new(
          :id => opts[:name],
          :name => opts[:name],
          :owner_id => credentials.user,
          :realm_id => dc.name,
          :state => 'PENDING',
          :instance_profile => InstanceProfile::new('default'),
          :actions => instance_actions_for( 'PENDING' )
        )
      end
    end

    # Reboot an instance, given its id.
    def reboot_instance(credentials, id)
      find_vm(credentials, id).ResetVM_Task
    end

    # Start an instance, given its id.
    def start_instance(credentials, id)
      find_vm(credentials, id).PowerOnVM_Task
    end

    # Stop an instance, given its id.
    def stop_instance(credentials, id)
      find_vm(credentials, id).PowerOffVM_Task
    end

    # Destroy an instance, given its id. Note that this will destory all
    # instance data.
    def destroy_instance(credentials, id)
      find_vm(credentials, id).Destroy_Task.wait_for_completion
    end

    exceptions do

      on /InvalidLogin/ do
        status 401
      end

      on /RbVmomi::Fault/ do
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
      endpoint = (Thread.current[:provider] || ENV['API_PROVIDER'])
      endpoint || Deltacloud::Drivers::driver_config[:vsphere][:entrypoints]['default']['default']
    end

    def list_virtual_machines(credentials)
      vsphere = new_client(credentials)
      vms = []
      rootFolder = vsphere.serviceInstance.content.rootFolder
      rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).each do |dc|
        vms += dc.vmFolder.childEntity.collect do |ent|
          if ent.class.name == 'RbVmomi::VIM::Folder'
            ent.childEntity.grep(RbVmomi::VIM::VirtualMachine).collect
          else
            ent
          end
        end
      end
      vms.flatten.compact
    end

    def find_vm(credentials, name)
      vsphere = new_client(credentials)
      safely do
        rootFolder = vsphere.serviceInstance.content.rootFolder
        dc = rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).collect.first
        dc.find_vm(name)
      end
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
      if object == :datacenter
        new_state = case state
          when 'gray', 'green' then 'AVAILABLE'
          else 'UNAVAILABLE'
        end
      end
      new_state
    end

    # Match hardware profile ID against given properties
    def match_hwp_id(prop)
      return 'small' if prop[:memory] == '256' and prop[:cpus] == '1'
      return 'medium' if prop[:memory] == '512' and prop[:cpus] == '1'
      return 'large' if prop[:memory] == '1024' and prop[:cpus] == '2'
      return 'x-large' if prop[:memory] == '2048' and prop[:cpus] == '4'
      'unknown'
    end


  end

end
