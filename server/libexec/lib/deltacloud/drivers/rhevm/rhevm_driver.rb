#
# Copyright (C) 2009  Red Hat, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require 'deltacloud/base_driver'
require 'yaml'

module Deltacloud
  module Drivers
    module RHEVM

class RHEVMDriver < Deltacloud::BaseDriver

  SCRIPT_DIR = File.dirname(__FILE__) + '/../scripts'
  CONFIG = YAML.load_file(RAILS_ROOT + '/config/rhevm_config.yml')
  SCRIPT_DIR_ARG = '"' + SCRIPT_DIR + '"'
  DELIM_BEGIN="<_OUTPUT>"
  DELIM_END="</_OUTPUT>"
  POWERSHELL="c:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe"
  NO_OWNER=""

  #
  # Execute a Powershell command, and convert the output
  # to YAML in order to get back an array of maps.
  #
  def execute(credentials, command, *args)
    args = args.to_a
    argString = genArgString(credentials, args)
    outputMaps = {}
    output = `#{POWERSHELL} -command "&{#{File.join(SCRIPT_DIR, command)} #{argString}; exit $LASTEXITCODE}`
    exitStatus = $?.exitstatus
    puts(output)
    puts("EXITSTATUS #{exitStatus}")
    st = output.index(DELIM_BEGIN)
    if (st)
      st += DELIM_BEGIN.length
      ed = output.index(DELIM_END)
      output = output.slice(st, (ed-st))
      # Lets make it yaml
      output.strip!
      if (output.length > 0)
        outputMaps = YAML.load(self.toYAML(output))
      end
    end
    outputMaps
  end

  def genArgString(credentials, args)
    commonArgs = [SCRIPT_DIR_ARG, credentials.name, credentials.password, CONFIG["domain"]]
    commonArgs.concat(args)
    commonArgs.join(" ")
  end

  def toYAML(output)
    yOutput = "- \n" + output
    yOutput.gsub!(/^(\w*)[ ]*:[ ]*([A-Z0-9a-z._ -:{}]*)/,' \1: "\2"')
    yOutput.gsub!(/^[ ]*$/,"- ")
    puts(yOutput)
    yOutput
  end

  def statify(state)
    st = state.nil? ? "" : state.upcase()
    return "running" if st == "UP"
    return "stopped" if st == "DOWN"
    return "pending" if st == "POWERING UP"
    st
  end

  #
  # Flavors
  #
  FLAVORS = [
    Flavor.new({
      :id=>"rhevm",
      :memory=>"Any Memory",
      :storage=>"Any Storage",
      :architecture=>"Any Architecture",
    })
  ]

  def flavors(credentials, opts=nil)
    return FLAVORS if ( opts.nil? || (! opts[:id]))
    FLAVORS.select{|f| opts[:id] == f.id}
  end


  #
  # Realms
  #

  def realms(credentials, opts=nil)
    domains = execute(credentials, "storageDomains.ps1")
    if (!opts.nil? && opts[:id])
        domains = domains.select{|d| opts[:id] == d["StorageId"]}
    end

    realms = []
    domains.each do |dom|
      realms << domain_to_realm(dom)
    end
    realms
  end

  def domain_to_realm(dom)
    Realm.new({
      :id => dom["StorageId"],
      :name => dom["Name"],
      :limit => dom["AvailableDiskSize"]
    })
  end



  #
  # Images
  #

  def images(credentials, opts=nil )
    templates = []
    if (opts.nil?)
      templates = execute(credentials, "templates.ps1")
    else
      if (opts[:id])
        templates = execute(credentials, "templateById.ps1", opts[:id])
      end
    end
    images = []
    templates.each do |templ|
      images << template_to_image(templ)
    end
    images
  end

  def template_to_image(templ)
    Image.new({
      :id => templ["TemplateId"],
      :name => templ["Name"],
      :description => templ["Description"],
      :architecture => templ["OperatingSystem"],
      :owner_id => NO_OWNER,
      :mem_size_md => templ["MemSizeMb"],
      :instance_count => templ["ChildCount"],
      :state => templ["Status"],
      :capacity => templ["SizeGB"]
    })
  end

  #
  # Instances
  #

  define_instance_states do
    start.to(:stopped)            .on( :create )

    pending.to(:shutting_down)    .on( :stop )
    pending.to(:running)          .automatically

    running.to(:pending)          .on( :reboot )
    running.to(:shutting_down)    .on( :stop )

    shutting_down.to(:stopped)    .automatically
    stopped.to(:pending)          .on( :start )
    stopped.to(:finish)           .on( :destroy )
  end

  def instances(credentials, opts=nil)
    vms = []
    if (opts.nil?)
      vms = execute(credentials, "vms.ps1")
    else
      if (opts[:id])
        vms = execute(credentials, "vmById.ps1", opts[:id])
      end
    end
    instances = []
    vms.each do |vm|
      instances << vm_to_instance(vm)
    end
    instances
  end

  def vm_to_instance(vm)
    Instance.new({
      :id => vm["VmId"],
      :description => vm["Description"],
      :name => vm["Name"],
      :architecture => vm["OperatingSystem"],
      :owner_id => NO_OWNER,
      :image_id => vm["TemplateId"],
      :state => statify(vm["Status"]),
      :flavor_id => "rhevm",
      :actions => instance_actions_for(statify(vm["Status"])),
    })
  end

  def start_instance(credentials, image_id)
    vm = execute(credentials, "startVm.ps1", image_id)
    vm_to_instance(vm[0])
  end

  def stop_instance(credentials, image_id)
    vm = execute(credentials, "stopVm.ps1", image_id)
    vm_to_instance(vm[0])
  end

  def create_instance(credentials, image_id, opts)
    name = opts[:name]
    name = "Inst-#{rand(10000)}" if (name.nil? or name.empty?)
    realm_id = opts[:realm_id]
    if (realm_id.nil?)
        realms = filter_on(realms(credentials, opts), :name, :name => "data")
        puts realms[0]
        realm_id = realms[0].id
    end
    vm = execute(credentials, "addVm.ps1", image_id, name, realm_id)
    vm_to_instance(vm[0])
  end

  def reboot_instance(credentials, image_id)
    vm = execute(credentials, "rebootVm.ps1", image_id)
    vm_to_instance(vm[0])
  end

  def destroy_instance(credentials, image_id)
    vm = execute(credentials, "deleteVm.ps1", image_id)
    vm_to_instance(vm[0])
  end

  #
  # Storage Volumes
  #

  def storage_volumes(credentials, ids=nil)
    volumes = []
    volumes
  end

  #
  # Storage Snapshots
  #

  def storage_snapshots(credentials, ids=nil)
    snapshots = []
    snapshots
  end

end

    end
  end
end
