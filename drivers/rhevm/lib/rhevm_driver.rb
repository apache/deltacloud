
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
    { 
      :id=>'m1-small',
      :memory=>1.7,
      :storage=>160,
      :architecture=>'i386',
    },
    {
      :id=>'m1-large', 
      :memory=>7.5,
      :storage=>850,
      :architecture=>'x86_64',
    },
    { 
      :id=>'m1-xlarge', 
      :memory=>15,
      :storage=>1690,
      :architecture=>'x86_64',
    },
    { 
      :id=>'c1-medium', 
      :memory=>1.7,
      :storage=>350,
      :architecture=>'x86_64',
    },
    { 
      :id=>'c1-xlarge', 
      :memory=>7,
      :storage=>1690,
      :architecture=>'x86_64',
    },
  ]

  def flavors(credentials, ids=nil)
    return FLAVORS if ( ids.nil? )
    FLAVORS.select{|f| ids.include?(f[:id])}
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
    yOutput.gsub!(/^(\w*)[ ]*:[ ]*([A-Z0-9a-z._ -:]*)/,' \1: "\2"')
    yOutput.gsub!(/^[ ]*$/,"- ")
    yOutput
  end
  
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
    {
      :id => templ["TemplateId"],
      :description => templ["Description"],
      :architecture => templ["OperatingSystem"],
      :owner_id => "Jar jar Binks"      
    }
  end

  # 
  # Instances
  # 

  def instances(credentials, ids=nil)
    instances = []
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
