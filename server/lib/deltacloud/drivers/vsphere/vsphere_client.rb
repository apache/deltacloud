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

module Deltacloud::Drivers::VSphere

  require 'deltacloud/drivers/vsphere/vsphere_filemanager'

  module Helper

    # Find a VirtualMachine traversing through all Datastores and Datacenters
    #
    # This helper will return a Hash: { :datastore => NAME_OF_DS, :instance => VM }
    # Returning datastore is necesarry for constructing a correct realm for an
    # instance
    #
    def find_vm(credentials, name)
      vsphere = new_client(credentials)
      safely do
        rootFolder = vsphere.serviceInstance.content.rootFolder
        vm = {}
        rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).each do |dc|
          dslist = list_datastores(dc.datastoreFolder)
          dslist.each do |datastore|
            vm[:instance] = datastore.vm.find { |x| x.name == name }
            if vm[:instance]
              vm[:datastore] = datastore.name
              break
            end
            stored_tasks(datastore, vsphere) do |task|
              if task.info.entity.class == RbVmomi::VIM::VirtualMachine and ['queued', 'running'].member? task.info.state
                vm = { :stored_instance => load_serialized_instance(datastore,task.info.key), :datastore => datastore.name }
              end
            end
          end
          break if [:datastore]
        end
        vm
      end
    end

    # Find a ResourcePool[1] object associated by given Datastore
    # ResourcePool is defined for Datacenter and is used for launching a new
    # instance
    #
    # [1] http://www.vmware.com/support/developer/vc-sdk/visdk41pubs/ApiReference/vim.ResourcePool.html
    #
    def find_resource_pool(credentials, name)
      vsphere = new_client(credentials)
      safely do
        rootFolder = vsphere.serviceInstance.content.rootFolder
        dc = rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).select do |dc|
          dc.datastoreFolder.childEntity.find { |d| d.name == name }.nil? == false
        end.flatten.compact.first
        dc = rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).first
        dc.hostFolder.childEntity.collect.first.resourcePool
      end
    end

    # This helper will try to find a Datastore[1] object in all Datacenters.
    # Datastore is used to place instance on create to correct place
    #
    # [1] http://www.vmware.com/support/developer/vc-sdk/visdk41pubs/ApiReference/vim.Datastore.html
    #
    def find_datastore(credentials, name)
      vsphere = new_client(credentials)
      safely do
        rootFolder = vsphere.serviceInstance.content.rootFolder
        rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).collect do |dc|
          list_datastores(dc.datastoreFolder).each do |d|
            if d.name == name
              return d
            end
          end
        end
      end
    end

    # This helper will traverse across all datacenters and datastores and gather
    # all virtual machines available on vSphere
    #
    def list_virtual_machines(credentials)
      vsphere = new_client(credentials)
      vms = []
      rootFolder = vsphere.serviceInstance.content.rootFolder
      rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).each do |dc|
        list_datastores(dc.datastoreFolder).each do  |datastore|
          vms += datastore.vm.collect { |vm| { :instance => vm, :datastore => datastore.name } unless vm.nil? }
          stored_tasks(datastore, vsphere) do |task|
            if task.info.entity.class == RbVmomi::VIM::VirtualMachine
              vms << { :stored_instance => load_serialized_instance(datastore, task.info.key), :datastore => datastore.name }
            end
          end
        end
      end
      vms.flatten.compact
    end

    # This helper will traverse across all datacenters and folders and gather
    # all datastores available on vSphere
    #
    def list_datastores(df)
      datastores = []
      df.childEntity.each do |object|
        if object.class.to_s == 'Folder'
          datastores += list_datastores(object)
        else
          datastores << object
        end
      end
      datastores
    end

    # Map given instance to task. Task name is used as a filename.
    #
    def map_task_to_instance(datastore, task_key, new_instance)
      VSphere::FileManager::store_mapping!(datastore, YAML::dump(new_instance).to_s, task_key)
      new_instance
    end

    def load_serialized_instance(datastore, task_key)
      VSphere::FileManager::load_mapping(datastore, task_key)
    end

    # Yield all tasks if they are included in mapper storage directory.
    def stored_tasks(datastore, vsphere)
      tasks = VSphere::FileManager::list_mappings(datastore)
      return [] if tasks.empty?
      vsphere.serviceInstance.content.taskManager.recentTask.each do |task|
        if tasks.include?(task.info.key) and ['queued', 'running'].member?(task.info.state)
          yield task
          tasks.delete(task.info.key)
        end
      end
      # Delete old left tasks
      tasks.select { |f| f =~ /task-(\d+)/ }.each do |task|
        VSphere::FileManager::delete_mapping!(datastore, task)
      end
    end

    def extract_architecture(text)
      'x86_64' if text.include?('64-bit')
      'i386' if text.include?('32-bit')
    end


  end

end
