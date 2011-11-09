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
require 'deltacloud/drivers/mock/mock_client'
require 'base64'

module Deltacloud::Drivers::Mock

  class MockDriver < Deltacloud::BaseDriver

    # If the provider is set to storage, pretend to be a storage-only
    # driver
    def supported_collections
      if api_provider == 'storage'
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
        :state=>'AVAILABLE'}),
      Realm.new({
        :id=>'eu',
        :name=>'Europe',
        :limit=>:unlimited,
        :state=>'AVAILABLE'}),
      ] ) unless defined?( REALMS )

    define_hardware_profile('m1-small') do
      cpu              1
      memory         1.7 * 1024
      storage        160
      architecture 'i386'
    end

    define_hardware_profile('m1-large') do
      cpu                (1..6)
      memory           ( 7680.. 15*1024), :default => 10 * 1024
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
    feature :instances, :user_data
    feature :instances, :authentication_key

    def initialize
      if ENV["DELTACLOUD_MOCK_STORAGE"]
        storage_root = ENV["DELTACLOUD_MOCK_STORAGE"]
      elsif ENV["USER"]
        storage_root = File::join("/var/tmp", "deltacloud-mock-#{ENV["USER"]}")
      else
        raise "Please set either the DELTACLOUD_MOCK_STORAGE or USER environment variable"
      end
      @client = Client.new(storage_root)
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
      images = @client.build_all(Image)
      images = filter_on( images, :id, opts )
      images = filter_on( images, :architecture, opts )
      if ( opts && opts[:owner_id] == 'self' )
        images = images.select{|e| e.owner_id == credentials.user }
      else
        images = filter_on( images, :owner_id, opts )
      end
      images.sort_by{|e| [e.owner_id,e.description]}
    end

    def create_image(credentials, opts={})
      check_credentials(credentials)
      instance = instance(credentials, :id => opts[:id])
      safely do
        raise 'CreateImageNotSupported' unless instance and instance.can_create_image?
        image = {
          :id => opts[:name],
          :name => opts[:name],
          :owner_id => 'root',
          :state => "AVAILABLE",
          :description => opts[:description],
          :architecture => 'i386'
        }
        @client.store(:images, image)
        Image.new(image)
      end
    end

    def destroy_image(credentials, id)
      check_credentials( credentials )
      @client.destroy(:images, id)
    end

    #
    # Instances
    #

    def instance(credentials, opts={})
      check_credentials( credentials )
      if instance = @client.load(:instances, opts[:id])
        Instance.new(instance)
      end
    end

    def instances(credentials, opts=nil)
      check_credentials( credentials )
      instances = @client.build_all(Instance)
      instances = filter_on( instances, :owner_id, :owner_id => credentials.user )
      instances = filter_on( instances, :id, opts )
      instances = filter_on( instances, :state, opts )
      instances
    end

    def create_instance(credentials, image_id, opts)
      check_credentials( credentials )
      ids = @client.members(:instances)

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
        :id => next_id,
        :name=>name,
        :state=>'RUNNING',
        :keyname => opts[:keyname],
        :image_id=>image_id,
        :owner_id=>credentials.user,
        :public_addresses=>[ InstanceAddress.new("#{image_id}.#{next_id}.public.com", :type => :hostname) ],
        :private_addresses=>[ InstanceAddress.new("#{image_id}.#{next_id}.private.com", :type => :hostname) ],
        :instance_profile => InstanceProfile.new(hwp.name, opts),
        :realm_id=>realm_id,
        :create_image=>true,
        :actions=>instance_actions_for( 'RUNNING' ),
        :user_data => opts[:user_data] ? Base64::decode64(opts[:user_data]) : nil
      }
      @client.store(:instances, instance)
      Instance.new( instance )
    end

    def update_instance_state(credentials, id, state)
      instance  = @client.load(:instances, id)
      instance[:state] = state
      instance[:actions] = instance_actions_for( instance[:state] )
      @client.store(:instances, instance)
      Instance.new( instance )
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
      @client.destroy(:instances, id)
    end

    #
    # Storage Volumes
    #

    def storage_volumes(credentials, opts=nil)
      check_credentials( credentials )
      volumes = @client.build_all(StorageVolume)
      volumes = filter_on( volumes, :id, opts )
      volumes
    end

    #
    # Storage Snapshots
    #

    def storage_snapshots(credentials, opts=nil)
      check_credentials( credentials )
      snapshots = @client.build_all(StorageSnapshot)
      snapshots = filter_on(snapshots, :id, opts )
      snapshots
    end

    def keys(credentials, opts={})
      check_credentials(credentials)
      result = @client.build_all(Key)
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

      raise "KeyExist" if @client.load(:keys, key_hash[:id])
      @client.store(:keys, key_hash)
      return Key.new(key_hash)
    end

    def destroy_key(credentials, opts={})
      key = key(credentials, opts)
      @client.destroy(:keys, key.id)
    end

    #--
    # Buckets
    #--
    def buckets(credentials, opts={})
      check_credentials(credentials)
      buckets = @client.build_all(Bucket)
      blob_map = @client.load_all(:blobs).inject({}) do |map, blob|
        map[blob[:bucket]] ||= []
        map[blob[:bucket]] << blob[:id]
        map
      end
      buckets.each { |bucket| bucket.blob_list = blob_map[bucket.id] }
      filter_on( buckets, :id, opts )
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
      @client.store(:buckets, bucket)
      Bucket.new(bucket)
    end

    #--
    # Delete bucket
    #--
    def delete_bucket(credentials, name, opts={})
      check_credentials(credentials)
      bucket = bucket(credentials, {:id => name})
      raise "BucketNotEmpty" unless (bucket.size == "0")
      @client.destroy(:buckets, bucket.id)
    end

    #--
    # Blobs
    #--
    def blobs(credentials, opts = {})
      check_credentials(credentials)
      blobs = @client.build_all(Blob)
      filter_on( blobs, :bucket, :bucket => opts['bucket'] )
      filter_on( blobs, :id, opts )
    end

    #--
    # Blob content
    #--
    def blob_data(credentials, bucket_id, blob_id, opts = {})
      check_credentials(credentials)
      if blob = @client.load(:blobs, blob_id)
        blob[:content].each {|part| yield part}
      end
    end

    #--
    # Create blob
    #--
    def create_blob(credentials, bucket_id, blob_id, blob_data, opts={})
      check_credentials(credentials)
      blob_meta = BlobHelper::extract_blob_metadata_hash(opts)
      blob = {
        :id => blob_id,
        :name => blob_id,
        :bucket => bucket_id,
        :content_length => blob_data[:tempfile].length,
        :content_type => blob_data[:type],
        :last_modified => Time.now,
        :user_metadata => BlobHelper::rename_metadata_headers(blob_meta, ''),
        :content => blob_data[:tempfile].read
      }
      @client.store(:blobs, blob)
      Blob.new(blob)
    end

    #--
    # Delete blob
    #--
    def delete_blob(credentials, bucket_id, blob_id, opts={})
      check_credentials(credentials)
      safely do
        raise "NotExistentBlob" unless @client.load(:blobs, blob_id)
        @client.destroy(:blobs, blob_id)
      end
    end

    #--
    # Get metadata
    #--
    def blob_metadata(credentials, opts={})
      check_credentials(credentials)
      if blob = @client.load(:blobs, params[:id])
        blob[:user_metadata]
      else
        nil
      end
    end

    #--
    # Update metadata
    #--
    def update_blob_metadata(credentials, opts={})
      check_credentials(credentials)
      safely do
        blob = @client.load(:blobs, params[:id])
        return false unless blob
        blob[:user_metadata] = BlobHelper::rename_metadata_headers(opts['meta_hash'], '')
        @client.store(:blobs, blob)
      end
    end

    def valid_credentials?(credentials)
      begin
        check_credentials(credentials)
        return true
      rescue
      end
      return false
    end

    private

    def check_credentials(credentials)
      safely do
        if ( credentials.user != 'mockuser' ) or ( credentials.password != 'mockpassword' )
          raise 'AuthFailure'
        end
      end
    end

    exceptions do

      on /AuthFailure/ do
        status 401
        message "Authentication Failure"
      end

      on /BucketNotEmpty/ do
        status 403
        message "Delete operation not valid for non-empty bucket"
      end

      on /KeyExist/ do
        status 403
        message "Key with same name already exists"
      end

      on /CreateImageNotSupported/ do
        status 500
      end

      on /NotExistentBlob/ do
        status 500
        message "Could not delete a non existent blob"
      end

      on /Err/ do
        status 500
      end

    end

  end

end
