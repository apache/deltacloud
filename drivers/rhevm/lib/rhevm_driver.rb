
require 'deltacloud/base_driver'
require 'yaml'

class RHEVMDriver < DeltaCloud::BaseDriver

  SCRIPT_DIR = File.dirname(__FILE__) + '/../scripts'
  SCRIPT_DIR_ARG = '"' + SCRIPT_DIR + '"'
  DELIM_BEGIN="<_OUTPUT>"
  DELIM_END="</_OUTPUT>"
  POWERSHELL="c:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe"
  
  # 
  # Flavors
  # 
  FLAVORS = [
    Flavor.new({ 
      :id=>"rhevm",
      :memory=>"Any",
      :storage=>"Any",
      :architecture=>"Any",
    })
  ]
  
  def flavors(credentials, opts=nil)
    return FLAVORS if ( opts.nil? )
    FLAVORS.select{|f| opts[:id] == f.id}
  end

  #
  # Execute a Powershell command, and convert the output
  # to YAML in order to get back an array of maps.
  #
  def execute(credentials, command, args=[])
    argString = genArgString(credentials, args)
    outputMaps = {}
    output = `#{POWERSHELL} -command "&{#{File.join(SCRIPT_DIR, command)} #{argString}; exit $LASTEXITCODE}`
    exitStatus = $?.exitstatus 
    puts(output)
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
    commonArgs = [SCRIPT_DIR_ARG, "vdcadmin", "123456", "demo"]
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
  
  
  #
  # Images
  #
  
  def images(credentials, opts=nil )
    templates = []
    if (opts.nil?)
      templates = execute(credentials, "templates.ps1")     
    else
      if (opts[:id]) 
        templates = execute(credentials, "templateById.ps1", [opts[:id]])
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
      :owner_id => "Jar Jar Binks",
      :mem_size_md => templ["MemSizeMb"],
      :instance_count => templ["ChildCount"],
      :state => templ["Status"],
      :capacity => templ["SizeGB"]
    })
  end

  # 
  # Instances
  # 

  def instances(credentials, opts=nil)
    vms = []
    if (opts.nil?)
      vms = execute(credentials, "vms.ps1")     
    else
      if (opts[:id]) 
        vms = execute(credentials, "vmsById.ps1", [opts[:id]])
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
      :owner_id => "Jar Jar Binks",
      :image_id => vm["TemplateId"],
      :state => vm["Status"],
      :flavor_id => "rhevm",      
    })
  end  

  def create_instance(credentials, image_id, flavor_id)
    check_credentials( credentials )
  end

  def reboot_instance(credentials, id)
  end

  def delete_instance(credentials, id)
  end

  # 
  # Storage Volumes
  # 

  def volumes(credentials, ids=nil)
    volumes = []
    volumes
  end

  # 
  # Storage Snapshots
  # 

  def snapshots(credentials, ids=nil)
    snapshots = []
    snapshots
  end

end
