
require 'deltacloud/base_driver'

class MockDriver < DeltaCloud::BaseDriver

  ( STORAGE_ROOT = MOCK_STORAGE_ROOT ) unless defined?( STORAGE_ROOT )

  # 
  # Flavors
  # 

  ( FLAVORS = [ 
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
  ] ) unless defined?( FLAVORS )

  def flavors(credentials, opts=nil)
    return FLAVORS if ( opts.nil? )
    results = FLAVORS
    results = filter_on( results, :id, opts )
    results = filter_on( results, :architecture, opts )
    results
  end

  # 
  # Images
  # 

  def images(credentials, opts=nil )
    check_credentials( credentials )
    images = []
    Dir[ "#{STORAGE_ROOT}/images/*.yml" ].each do |image_file|
      image = YAML.load( File.read( image_file ) )
      image[:id] = File.basename( image_file, ".yml" )
      images << image
    end
    images = filter_on( images, :id, opts )
    images = filter_on( images, :architecture, opts )
    if ( opts && opts[:owner_id] == 'self' )
       images = images.select{|e| e[:owner_id] == credentials[:name] }
    else
      images = filter_on( images, :owner_id, opts )
    end
    images.sort_by{|e| [e[:owner_id],e[:description]]}
  end

  # 
  # Instances
  # 

  def instances(credentials, opts=nil)
    check_credentials( credentials )
    instances = []
    Dir[ "#{STORAGE_ROOT}/instances/*.yml" ].each do |instance_file|
      instance = YAML.load( File.read( instance_file ) )
      puts "opts ==> #{opts.inspect}"
      if ( instance[:owner_id] == credentials[:name] )
        instance[:id] = File.basename( instance_file, ".yml" )
        instances << instance
      end
    end
    instances = filter_on( instances, :id, opts )
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

  def volumes(credentials, opts=nil)
    volumes = []
    volumes
  end

  # 
  # Storage Snapshots
  # 

  def snapshots(credentials, opts=nil)
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
