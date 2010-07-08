
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
    if ( opts[:id] )
      if ( opts[:id].is_a?( Array ) )
        results = results.select{|f| opts[:id].include?( f[:id] )}
      else
        results = results.select{|f| opts[:id] == f[:id]}
      end
    end
    if ( opts[:architecture] )
      if ( opts[:architecture].is_a?( Array ) )
        results = results.select{|f| opts[:architecture].include?( f[:architecture] )}
      else
        results = results.select{|f| opts[:architecture] == f[:architecture]}
      end
    end
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
    if (opts)
      if ( opts[:id] )
        images = images.select{|e| e[:id] == opts[:id]}
      elsif ( opts[:owner_id] )
        if ( opts[:owner_id] == 'self' )
          images = images.select{|e| e[:owner_id] == credentials[:name] }
        else
          images = images.select{|e| e[:owner_id] == opts[:owner_id] }
        end
      elsif
        images = []
      end
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
        if ( opts.nil? || ( opts[:id].nil? ) )
          instances << instance
        else 
          if ( opts[:id].is_a?( Array ) )
            if ( opts[:id].include?( instance[:id] )  )
              puts "1D"
              instances << instance
            end
          elsif ( opts[:id] == instance[:id] )
            instances << instance
          end
        end
      end
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
