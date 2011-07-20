module Deltacloud::Drivers::VSphere

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
          dc.datastoreFolder.childEntity.collect do |datastore|
            vm[:instance] = datastore.vm.find { |x| x.name == name }
            if vm[:instance]
              vm[:datastore] = datastore.name
              break
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
          dc.datastoreFolder.childEntity.find { |d| d.name == name }
        end.flatten.compact.first
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
        dc.datastoreFolder.childEntity.collect do |datastore|
          vms += datastore.vm.collect { |vm| { :instance => vm, :datastore => datastore.name } unless vm.nil? }
        end
      end
      vms.flatten.compact
    end

    def map_task_to_instance(task_key, new_instance)
      FileUtils::mkdir_p(MAPPER_STORAGE_ROOT) unless File::directory?(MAPPER_STORAGE_ROOT)
      File::open(File::join(MAPPER_STORAGE_ROOT, task_key), "w") do |f|
        f.puts(YAML::dump(new_instance))
      end
      new_instance
    end

    def load_serialized_instance(task_key)
      FileUtils::mkdir_p(MAPPER_STORAGE_ROOT) unless File::directory?(MAPPER_STORAGE_ROOT)
      YAML::load(File::read(File::join(MAPPER_STORAGE_ROOT, task_key))) rescue nil
    end

    # Yield all tasks if they are included in mapper storage directory.
    def stored_tasks(vsphere)
      FileUtils::mkdir_p(MAPPER_STORAGE_ROOT) unless File::directory?(MAPPER_STORAGE_ROOT)
      tasks = Dir[File::join(MAPPER_STORAGE_ROOT, '*')].collect { |file| File::basename(file) }
      vsphere.serviceInstance.content.taskManager.recentTask.each do |task|
        if tasks.include?(task.info.key)
          yield task
        else
          # If given task is not longer listed in 'recentTasks' delete the
          # mapper file
          FileUtils::rm_rf(File::join(MAPPER_STORAGE_ROOT, task.info.key))
        end
      end
    end

    def extract_architecture(text)
      'x86_64' if text.include?('64-bit')
      'i386' if text.include?('32-bit')
    end


  end

end
