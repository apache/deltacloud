
require 'deltacloud/base_driver'
require 'yaml'

class RHEVMDriver < DeltaCloud::BaseDriver

  SCRIPT_DIR = File.dirname(__FILE__) + '/../scripts'
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
  
  DELIM_BEGIN="<_OUTPUT>"
  DELIM_END="</_OUTPUT>"  

  def flavors(credentials, ids=nil)
    return FLAVORS if ( ids.nil? )
    FLAVORS.select{|f| ids.include?(f[:id])}
  end

  # 
  # Images
  # 
  
  def execute(command, args=[])
    output = `c:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe #{File.join(SCRIPT_DIR, command)}`
    result = $?
    st = output.index(DELIM_BEGIN)
    if (st)
      st += DELIM_BEGIN.length
      ed = output.index(DELIM_END)
      output = output.slice(st, (ed-st))
      # Lets make it yaml
      output.strip!
      output = "- \n" + output
      output.gsub!(/^(\w*)[ ]*:[ ]*([A-Z0-9a-z._ -:]*)/,' \1: "\2"')
      output.gsub!(/^[ ]*$/,"- ")
    end
    outputMaps = YAML.load(output)    
    outputMaps 
  end
  
  def images(credentials, ids_or_owner=nil )
    templates = execute("images.ps1") 
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
