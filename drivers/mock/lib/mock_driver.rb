
require 'deltacloud/base_driver'

class MockDriver < DeltaCloud::BaseDriver

  STORAGE_ROOT = File.dirname(__FILE__) + '/../data'

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
    check_credentials( credentials )
    images = []
    Dir[ "#{STORAGE_ROOT}/images/*.yml" ].each do |image_file|
      image = YAML.load( File.read( image_file ) )
      image[:id] = File.basename( image_file, ".yml" )
      images << image
    end
    if ( ids_or_owner.is_a?( Array ) )
      images = images.select{|e| ids_or_owner.include?( e[:id] )} 
    elsif ( ids_or_owner == 'self' )
      images = images.select{|e| e[:owner_id] == credentials[:name] }
    elsif ( ! ids_or_owner.nil? )
      images = images.select{|e| e[:owner_id] == ids_or_owner }
    end
    images.sort_by{|e| [e[:owner_id],e[:description]]}
  end

  # 
  # Instances
  # 

  def instances(credentials, ids=nil)
    check_credentials( credentials )
    instances = []
    Dir[ "#{STORAGE_ROOT}/instances/*.yml" ].each do |instance_file|
      instance = YAML.load( File.read( instance_file ) )
      if ( instance[:owner_id] == credentials[:name] )
        instance[:id] = File.basename( instance_file, ".yml" )
        instances << instance
      end
    end
    unless ( ids.nil? || ids.empty? )
      instances = instances.select{|e| ids.include?( e[:id] )} 
    end
    instances
  end

  def create_instance(credentials, image_id, flavor_id)
    check_credentials( credentials )
    ids = Dir[ "#{STORAGE_ROOT}/instances/*.yml" ].collect{|e| File.basename( e, ".yml" )}
    next_id = ids.sort.last.succ
    instance = {
      :state=>'running',
      :image_id=>image_id,
      :owner_id=>credentials[:name],
      :public_address=>"#{image_id}.#{next_id}.public.com",
      :private_address=>"#{image_id}.#{next_id}.private.com",
      :flavor_id=>flavor_id,
    }
    File.open( "#{STORAGE_ROOT}/instances/#{next_id}.yml", 'w' ) {|f|
      YAML.dump( instance, f )
    }
    instance[:id] = next_id
    instance
  end

  def reboot_instance(credentials, id)
  end

  def delete_instance(credentials, id)
    check_credentials( credentials )
    FileUtils.rm( "#{STORAGE_ROOT}/instances/#{id}.yml" )
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

  private

  def check_credentials(credentials)
    if ( credentials[:name] != 'mockuser' )
      raise DeltaCloud::AuthException.new
    end

    if ( credentials[:password] != 'mockpassword' )
      raise DeltaCloud::AuthException.new
    end
  end


end
