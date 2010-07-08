
require 'deltacloud/base_driver'

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

  def flavors(credentials, ids=nil)
    return FLAVORS if ( ids.nil? )
    FLAVORS.select{|f| ids.include?(f[:id])}
  end

  # 
  # Images
  # 

  def images(credentials, ids_or_owner=nil )
    foo = `c:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe #{File.join(SCRIPT_DIR, "instances.ps1")}`
    puts(foo) 
    images = []
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
