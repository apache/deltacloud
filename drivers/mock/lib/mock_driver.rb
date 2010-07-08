
require 'deltacloud/base_driver'

class MockDriver < DeltaCloud::BaseDriver

  ( STORAGE_ROOT = MOCK_STORAGE_ROOT ) unless defined?( STORAGE_ROOT )

  #
  # Flavors
  #

  ( FLAVORS = [
    Flavor.new({
      :id=>'m1-small',
      :memory=>1.7,
      :storage=>160,
      :architecture=>'i386',
    }),
    Flavor.new({
      :id=>'m1-large',
      :memory=>7.5,
      :storage=>850,
      :architecture=>'x86_64',
    }),
    Flavor.new({
      :id=>'m1-xlarge',
      :memory=>15,
      :storage=>1690,
      :architecture=>'x86_64',
    }),
    Flavor.new({
      :id=>'c1-medium',
      :memory=>1.7,
      :storage=>350,
      :architecture=>'x86_64',
    }),
    Flavor.new({
      :id=>'c1-xlarge',
      :memory=>7,
      :storage=>1690,
      :architecture=>'x86_64',
    }),
  ] ) unless defined?( FLAVORS )

  ( REALMS = [
    Realm.new({
      :id=>'us',
      :name=>'United States',
      :limit=>:unlimited,
      :state=>'AVAILABLE',
    }),
    Realm.new({
      :id=>'eu',
      :name=>'Europe',
      :limit=>:unlimited,
      :state=>'AVAILABLE',
    }),
  ] ) unless defined?( REALMS )

  ( INSTANCE_STATES = [
    [ :begin, {
       :pending=>:create
     } ],
    [ :pending, {
       :running=>:_auto_
     } ],
     [ :running, {
       :running=>:reboot,
       :stopped=>:stop
     } ],
     [ :stopped, {
       :running=>:start,
       :end=>:destroy
     } ],
  ] ) unless defined?( STATES )


  def instance_states()
    return INSTANCE_STATES
  end

  def flavors(credentials, opts=nil)
    return FLAVORS if ( opts.nil? )
    results = FLAVORS
    results = filter_on( results, :id, opts )
    results = filter_on( results, :architecture, opts )
    results
  end

  def realms(credentials, opts=nil)
    return REALMS if ( opts.nil? )
    results = REALMS
    results = filter_on( results, :id, opts )
    results
  end

  #
  # Images
  #

  def images(credentials, opts=nil )
    check_credentials( credentials )
    puts(STORAGE_ROOT)
    images = []
    Dir[ "#{STORAGE_ROOT}/images/*.yml" ].each do |image_file|
      image = YAML.load( File.read( image_file ) )
      image[:id] = File.basename( image_file, ".yml" )
      images << Image.new( image )
    end
    images = filter_on( images, :id, opts )
    images = filter_on( images, :architecture, opts )
    if ( opts && opts[:owner_id] == 'self' )
      images = images.select{|e| e.owner_id == credentials[:name] }
    else
      images = filter_on( images, :owner_id, opts )
    end
    images.sort_by{|e| [e.owner_id,e.description]}
  end

  #
  # Instances
  #

  def instances(credentials, opts=nil)
    check_credentials( credentials )
    instances = []
    Dir[ "#{STORAGE_ROOT}/instances/*.yml" ].each do |instance_file|
      instance = YAML.load( File.read( instance_file ) )
      if ( instance[:owner_id] == credentials[:name] )
        instance[:id] = File.basename( instance_file, ".yml" )
        instance[:actions] = instance_actions_for( instance[:state] )
        instances << Instance.new( instance )
      end
    end
    instances = filter_on( instances, :id, opts )
    instances
  end

  def create_instance(credentials, image_id, opts)
    check_credentials( credentials )
    ids = Dir[ "#{STORAGE_ROOT}/instances/*.yml" ].collect{|e| File.basename( e, ".yml" )}
    next_id = ids.sort.last.succ

    realm_id = opts[:realm_id]
    if ( realm_id.nil? )
      realm = realms(credentials).first
      ( realm_id = realm.id ) if realm
    end

    flavor_id = opts[:flavor_id]
    if ( flavor_id.nil? )
      image = image(credentials, :id=>image_id )
      flavor = flavors(credentials, :architecture=>image.architecture).first
      (flavor_id = flavor.id ) if flavor
    end

    instance = {
      :state=>'RUNNING',
      :image_id=>image_id,
      :owner_id=>credentials[:name],
      :public_addresses=>["#{image_id}.#{next_id}.public.com"],
      :private_addresses=>["#{image_id}.#{next_id}.private.com"],
      :flavor_id=>flavor_id,
      :realm_id=>realm_id,
      :actions=>instance_actions_for( 'RUNNING' )
    }
    File.open( "#{STORAGE_ROOT}/instances/#{next_id}.yml", 'w' ) {|f|
      YAML.dump( instance, f )
    }
    instance[:id] = next_id
    Instance.new( instance )
  end

  def start_instance(credentials, id)
    instance_file = "#{STORAGE_ROOT}/instances/#{id}.yml"
    instance_yml  = YAML.load( File.read( instance_file ) )
    instance_yml[:state] = 'RUNNING'
    File.open( instance_file, 'w' ) do |f|
      f << YAML.dump( instance_yml ) 
    end
    Instance.new( instance_yml )
  end

  def reboot_instance(credentials, id)
    instance_file = "#{STORAGE_ROOT}/instances/#{id}.yml"
    instance_yml  = YAML.load( File.read( instance_file ) )
    instance_yml[:state] = 'RUNNING'
    File.open( instance_file, 'w' ) do |f|
      f << YAML.dump( instance_yml ) 
    end
    Instance.new( instance_yml )
  end

  def stop_instance(credentials, id)
    puts "STOP INSTANCE #{id}"
    instance_file = "#{STORAGE_ROOT}/instances/#{id}.yml"
    instance_yml  = YAML.load( File.read( instance_file ) )
    instance_yml[:state] = 'STOPPED'
    File.open( instance_file, 'w' ) do |f|
      f << YAML.dump( instance_yml )
    end
    puts "returning #{instance_yml.inspect}"
    Instance.new( instance_yml )
  end


  def destroy_instance(credentials, id)
    check_credentials( credentials )
    FileUtils.rm( "#{STORAGE_ROOT}/instances/#{id}.yml" )
  end

  #
  # Storage Volumes
  #

  def storage_volumes(credentials, opts=nil)
    check_credentials( credentials )
    volumes = []
    Dir[ "#{STORAGE_ROOT}/storage_volumes/*.yml" ].each do |storage_volume_file|
      storage_volume = YAML.load( File.read( storage_volume_file ) )
      if ( storage_volume[:owner_id] == credentials[:name] )
        storage_volume[:id] = File.basename( storage_volume_file, ".yml" )
        volumes << StorageVolume.new( storage_volume )
      end
    end
    volumes = filter_on( volumes, :id, opts )
    volumes
  end

  #
  # Storage Snapshots
  #

  def storage_snapshots(credentials, opts=nil)
    check_credentials( credentials )
    snapshots = []
    Dir[ "#{STORAGE_ROOT}/storage_snapshots/*.yml" ].each do |storage_snapshot_file|
      storage_snapshot = YAML.load( File.read( storage_snapshot_file ) )
      if ( storage_snapshot[:owner_id] == credentials[:name] )
        storage_snapshot[:id] = File.basename( storage_snapshot_file, ".yml" )
        snapshots << StorageSnapshot.new( storage_snapshot )
      end
    end
    snapshots = filter_on( snapshots, :id, opts )
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
