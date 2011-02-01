#
# Copyright (C) 2009, 2010  Red Hat, Inc.
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.


require 'deltacloud/base_driver'
require 'yaml'

module Deltacloud
  module Drivers
    module Mock
class MockDriver < Deltacloud::BaseDriver

  # If the provider is set to storage, pretend to be a storage-only
  # driver
  def supported_collections
    endpoint = Thread.current[:provider] || ENV['API_PROVIDER']
    if endpoint == 'storage'
      [:buckets]
    else
      DEFAULT_COLLECTIONS + [:buckets, :keys]
    end
  end

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

  define_hardware_profile('m1-small') do
    cpu              1
    memory         1.7 * 1024
    storage        160
    architecture 'i386'
  end

  define_hardware_profile('m1-large') do
    cpu                2
    memory           (7.5*1024 .. 15*1024), :default => 10 * 1024
    storage          [ 850, 1024 ]
    architecture     'x86_64'
  end

  define_hardware_profile('m1-xlarge') do
    cpu              4
    memory           (12*1024 .. 32*1024)
    storage          [ 1024, 2048, 4096 ]
    architecture     'x86_64'
  end

  # Some clouds tell us nothing about hardware profiles (e.g., OpenNebula)
  define_hardware_profile 'opaque'

  define_instance_states do
    start.to( :pending )       .on( :create )

    pending.to( :running )     .automatically

    running.to( :running )     .on( :reboot )
    running.to( :stopped )     .on( :stop )

    stopped.to( :running )     .on( :start )
    stopped.to( :finish )      .on( :destroy )
  end

  feature :instances, :user_name
  feature :instances, :authentication_key

  def initialize
    if ENV["DELTACLOUD_MOCK_STORAGE"]
      @storage_root = ENV["DELTACLOUD_MOCK_STORAGE"]
    elsif ENV["USER"]
      @storage_root = File::join("/var/tmp", "deltacloud-mock-#{ENV["USER"]}")
    else
      raise "Please set either the DELTACLOUD_MOCK_STORAGE or USER environment variable"
    end
    if ! File::directory?(@storage_root)
      FileUtils::rm_rf(@storage_root)
      FileUtils::mkdir_p(@storage_root)
      data = Dir::glob(File::join(File::dirname(__FILE__), "data", "*"))
      FileUtils::cp_r(data, @storage_root)
    end
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
    images = []
    Dir[ "#{@storage_root}/images/*.yml" ].each do |image_file|
      image = YAML.load( File.read( image_file ) )
      image[:id] = File.basename( image_file, ".yml" )
      image[:name] = image[:description]
      images << Image.new( image )
    end
    images = filter_on( images, :id, opts )
    images = filter_on( images, :architecture, opts )
    if ( opts && opts[:owner_id] == 'self' )
      images = images.select{|e| e.owner_id == credentials.user }
    else
      images = filter_on( images, :owner_id, opts )
    end
    images.sort_by{|e| [e.owner_id,e.description]}
  end

  #
  # Instances
  #

  def instance(credentials, opts={})
    check_credentials( credentials )
    instance_filename = File.join(@storage_root, 'instances', "#{opts[:id]}.yml")
    return nil unless File.exists?(instance_filename)
    instance = YAML::load_file(instance_filename)
    instance[:actions] = instance_actions_for( instance[:state] )
    instance[:id] = File::basename(instance_filename, ".yml")
    Instance.new(instance)
  end

  def instances(credentials, opts=nil)
    check_credentials( credentials )
    instances = []
    Dir[ "#{@storage_root}/instances/*.yml" ].each do |instance_file|
      instance = YAML::load_file(instance_file)
      if ( instance[:owner_id] == credentials.user )
        instance[:id] = File.basename( instance_file, ".yml" )
        instance[:actions] = instance_actions_for( instance[:state] )
        instances << Instance.new( instance )
      end
    end
    instances = filter_on( instances, :id, opts )
    instances = filter_on( instances, :state, opts )
    instances
  end

  def create_instance(credentials, image_id, opts)
    check_credentials( credentials )
    ids = Dir[ "#{@storage_root}/instances/*.yml" ].collect{|e| File.basename( e, ".yml" )}

    count = 0
    while true
      next_id = "inst" + count.to_s
      if not ids.include?(next_id)
        break
      end
      count = count + 1
    end

    realm_id = opts[:realm_id]
    if ( realm_id.nil? )
      realm = realms(credentials).first
      ( realm_id = realm.id ) if realm
    end

    hwp = find_hardware_profile(credentials, opts[:hwp_id], image_id)

    name = opts[:name] || "i-#{Time.now.to_i}"

    instance = {
      :name=>name,
      :state=>'RUNNING',
      :image_id=>image_id,
      :owner_id=>credentials.user,
      :public_addresses=>["#{image_id}.#{next_id}.public.com"],
      :private_addresses=>["#{image_id}.#{next_id}.private.com"],
      :instance_profile => InstanceProfile.new(hwp.name, opts),
      :realm_id=>realm_id,
      :actions=>instance_actions_for( 'RUNNING' )
    }
    File.open( "#{@storage_root}/instances/#{next_id}.yml", 'w' ) {|f|
      YAML.dump( instance, f )
    }
    instance[:id] = next_id
    Instance.new( instance )
  end

  def update_instance_state(credentials, id, state)
    instance_file = "#{@storage_root}/instances/#{id}.yml"
    instance_yml  = YAML.load( File.read( instance_file ) )
    instance_yml[:id] = id
    instance_yml[:state] = state
    instance_yml[:actions] = instance_actions_for( instance_yml[:state] )
    File.open( instance_file, 'w' ) do |f|
      f << YAML.dump( instance_yml )
    end
    Instance.new( instance_yml )
  end

  def start_instance(credentials, id)
    update_instance_state(credentials, id, 'RUNNING')
  end

  def reboot_instance(credentials, id)
    update_instance_state(credentials, id, 'RUNNING')
  end

  def stop_instance(credentials, id)
    update_instance_state(credentials, id, 'STOPPED')
  end


  def destroy_instance(credentials, id)
    check_credentials( credentials )
    FileUtils.rm( "#{@storage_root}/instances/#{id}.yml" )
  end

  #
  # Storage Volumes
  #

  def storage_volumes(credentials, opts=nil)
    check_credentials( credentials )
    volumes = []
    Dir[ "#{@storage_root}/storage_volumes/*.yml" ].each do |storage_volume_file|
      storage_volume = YAML.load( File.read( storage_volume_file ) )
      if ( storage_volume[:owner_id] == credentials.user )
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
    Dir[ "#{@storage_root}/storage_snapshots/*.yml" ].each do |storage_snapshot_file|
      storage_snapshot = YAML.load( File.read( storage_snapshot_file ) )
      if ( storage_snapshot[:owner_id] == credentials.user )
        storage_snapshot[:id] = File.basename( storage_snapshot_file, ".yml" )
        snapshots << StorageSnapshot.new( storage_snapshot )
      end
    end
    snapshots = filter_on( snapshots, :id, opts )
    snapshots
  end

  def keys(credentials, opts={})
    check_credentials(credentials)
    result = []
    key_dir = File.join(@storage_root, 'keys')
    Dir[key_dir + '/*.yml'].each do |key_file|
      result << Key.new(YAML::load(File.read(key_file)))
    end
    result = filter_on( result, :id, opts )
    result
  end

  def key(credentials, opts={})
    keys(credentials, opts).first
  end

  def create_key(credentials, opts={})
    check_credentials(credentials)
    key_hash = {
      :id => opts[:key_name],
      :credential_type => :key,
      :fingerprint => Key::generate_mock_fingerprint,
      :pem_rsa_key => Key::generate_mock_pem
    }
    key_dir = File.join(@storage_root, 'keys')
    if File.exists?(key_dir + "/#{key_hash[:id]}.yml")
     raise Deltacloud::BackendError.new(403, self.class.to_s, "key-exists",
                                          ["Key with same name already exists"])
    end
    FileUtils.mkdir_p(key_dir) unless File.directory?(key_dir)
    File.open(key_dir + "/#{key_hash[:id]}.yml", 'w') do |f|
      f.puts(YAML::dump(key_hash))
    end
    return Key.new(key_hash)
  end

  def destroy_key(credentials, opts={})
    key = key(credentials, opts)
    safely do
      key_dir = File.join(@storage_root, 'keys')
      File.delete(key_dir + "/#{key.id}.yml")
    end
  end

#--
# Buckets
#--
  def buckets(credentials, opts={})
    check_credentials(credentials)
    buckets=[]
     Dir[ "#{@storage_root}/buckets/*.yml" ].each do |bucket_file|
      bucket = YAML.load( File.read( bucket_file ) )
      bucket[:id] = File.basename( bucket_file, ".yml" )
      bucket[:name] = bucket[:id]
      buckets << Bucket.new( bucket )
    end
    buckets = filter_on( buckets, :id, opts )
    buckets
  end

#--
# Create bucket
#--
  def create_bucket(credentials, name, opts={})
    check_credentials(credentials)
    bucket = {
      :id => name,
      :name=>name,
      :size=>'0',
      :blob_list=>[]
    }
    File.open( "#{@storage_root}/buckets/#{name}.yml", 'w' ) {|b| YAML.dump( bucket, b )}
    Bucket.new(bucket)
  end

#--
# Delete bucket
#--
  def delete_bucket(credentials, name, opts={})
    bucket = bucket(credentials, {:id => name})
    unless (bucket.size == "0")
     raise Deltacloud::BackendError.new(403, self.class.to_s, "bucket-not-empty", "delete operation not valid for non-empty bucket")
    end
    safely do
      File.delete("#{@storage_root}/buckets/#{name}.yml")
    end
  end

#--
# Blobs
#--
  def blobs(credentials, opts = {})
    check_credentials(credentials)
    blobs=[]
    Dir[ "#{@storage_root}/buckets/blobs/*.yml" ].each do |blob_file|
      blob = YAML.load( File.read( blob_file ) )
      blob[:id] = File.basename( blob_file, ".yml" )
      blob[:name] = blob[:id]
      blobs << Blob.new( blob )
    end
    blobs = filter_on( blobs, :id, opts )
    blobs
  end

#--
# Blob content
#--
  def blob_data(credentials, bucket_id, blob_id, opts = {})
    check_credentials(credentials)
    blob=nil
    Dir[ "#{@storage_root}/buckets/blobs/*.yml" ].each do |blob_file|
      if File.basename(blob_file, ".yml") == blob_id
        blob = YAML.load(File.read(blob_file))
        blob[:content].each {|part| yield part}
      end
    end
  end

  def valid_credentials?(credentials)
    begin
      check_credentials(credentials)
      return true
    rescue Deltacloud::AuthException
    end
    return false
  end

  private

  def check_credentials(credentials)
    if ( credentials.user != 'mockuser' )
      raise Deltacloud::AuthException.new
    end

    if ( credentials.password != 'mockpassword' )
      raise Deltacloud::AuthException.new
    end
  end


end

    end
  end
end
