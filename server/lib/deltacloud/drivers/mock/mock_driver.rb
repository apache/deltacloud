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

require 'yaml'
require 'base64'
require 'etc'
require 'ipaddr'

require_relative 'mock_client'
require_relative 'mock_driver_cimi_methods'
require_relative '../../runner'

module Deltacloud::Drivers::Mock

  class MockDriver < Deltacloud::BaseDriver

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
      cpu              (1..6)
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
    feature :instances, :metrics
    feature :instances, :realm_filter
    feature :images, :user_name
    feature :images, :user_description

    def initialize
      if ENV["DELTACLOUD_MOCK_STORAGE"]
        storage_root = ENV["DELTACLOUD_MOCK_STORAGE"]
      elsif Etc.getlogin
        storage_root = File::join("/var/tmp", "deltacloud-mock-#{ENV["USER"]}")
      else
        raise "Please set either the DELTACLOUD_MOCK_STORAGE or USER environment variable"
      end
      @client = Client.new(storage_root)
    end

    def realms(credentials, opts={})
      check_credentials( credentials )
      results = []
      safely do
        # This hack is used to test if client capture exceptions correctly
        # To raise an exception do GET /api/realms/50[0-2]
        raise "DeltacloudErrorTest" if opts and opts[:id] == "500"
        raise "NotImplementedTest" if opts and opts[:id] == "501"
        raise "ProviderErrorTest" if opts and opts[:id] == "502"
        raise "ProviderTimeoutTest" if opts and opts[:id] == "504"
        results = REALMS
      end
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
      images = images.map { |i| (i.hardware_profiles = hardware_profiles(nil)) && i }
      images.sort_by{|e| [e.owner_id, e.description]}
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

    def instances(credentials, opts={})
      check_credentials( credentials )
      instances = @client.build_all(Instance)
      instances = filter_on( instances, :owner_id, :owner_id => credentials.user )
      instances = filter_on( instances, :id, opts )
      instances = filter_on( instances, :state, opts )
      instances = filter_on( instances, :realm_id, opts)
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
      hwp ||= find_hardware_profile(credentials, 'm1-small', image_id)

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

    # mock object to mimick Net::SSH object
    class Mock_ssh
      attr_accessor :command
    end

    def run_on_instance(credentials, opts={})
      ssh = Mock_ssh.new
      ssh.command = opts[:cmd]
      Deltacloud::Runner::Response.new(ssh, "This is where the output would appear if this were not a mock provider")
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

    def create_storage_volume(credentials, opts={})
      check_credentials(credentials)
      opts[:capacity] ||= "1"
      id = "Volume#{Time.now.to_i}"
      volume = {
            :id => id,
            :name => opts[:name] ? opts[:name] : id,
            :created => Time.now.to_s,
            :state => "AVAILABLE",
            :capacity => opts[:capacity],
      }
      @client.store(:storage_volumes, volume)
      StorageVolume.new(volume)
    end

    def destroy_storage_volume(credentials, opts={})
      check_credentials(credentials)
      @client.destroy(:storage_volumes, opts[:id])
    end

    #opts: {:id=,:instance_id,:device}
    def attach_storage_volume(credentials, opts={})
      check_credentials(credentials)
      attach_volume_instance(opts[:id], opts[:device], opts[:instance_id])
    end

    def detach_storage_volume(credentials, opts)
      check_credentials(credentials)
      detach_volume_instance(opts[:id], opts[:instance_id])
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
      safely do
        raise "KeyExist" if @client.load(:keys, key_hash[:id])
        @client.store(:keys, key_hash)
      end
      return Key.new(key_hash)
    end

    def destroy_key(credentials, opts={})
      key = key(credentials, opts)
      @client.destroy(:keys, key.id)
    end

    def addresses(credentials, opts={})
      check_credentials(credentials)
      addresses = @client.build_all(Address)
      addresses = filter_on( addresses, :id, opts )
    end

    def create_address(credentials, opts={})
      check_credentials(credentials)
      address = {:id => allocate_mock_address.to_s, :instance_id=>nil}
      @client.store(:addresses, address)
      Address.new(address)
    end

    def destroy_address(credentials, opts={})
      check_credentials(credentials)
      address = @client.load(:addresses, opts[:id])
      raise "AddressInUse" unless address[:instance_id].nil?
      @client.destroy(:addresses, opts[:id])
    end

    def associate_address(credentials, opts={})
      check_credentials(credentials)
      address = @client.load(:addresses, opts[:id])
      raise "AddressInUse" unless address[:instance_id].nil?
      instance = @client.load(:instances, opts[:instance_id])
      address[:instance_id] = instance[:id]
      instance[:public_addresses] = [InstanceAddress.new(address[:id])]
      @client.store(:addresses, address)
      @client.store(:instances, instance)
    end

    def disassociate_address(credentials, opts={})
      check_credentials(credentials)
      address = @client.load(:addresses, opts[:id])
      raise "AddressNotInUse" unless address[:instance_id]
      instance = @client.load(:instances, address[:instance_id])
      address[:instance_id] = nil
      instance[:public_addresses] = [InstanceAddress.new("#{instance[:image_id]}.#{instance[:id]}.public.com", :type => :hostname)]
      @client.store(:addresses, address)
      @client.store(:instances, instance)
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
      raise 'BucketNotExist' if bucket.nil?
      raise "BucketNotEmpty" unless bucket.blob_list.empty?
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
        #give event machine a chance
        sleep 1
        blob[:content].split('').each {|part| yield part}
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
        :last_modified => Time.now,
        :user_metadata => BlobHelper::rename_metadata_headers(blob_meta, ''),
      }
      if blob_data.kind_of? Hash
        blob_data[:tempfile].rewind
        blob.merge!({
          :content_length => blob_data[:tempfile].length,
          :content_type => blob_data[:type],
          :content => blob_data[:tempfile].read
        })
      elsif blob_data.kind_of? String
        blob.merge!({
          :content_length => blob_data.size,
          :content_type => 'text/plain',
          :content => blob_data
        })
      end
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
      if blob = @client.load(:blobs, opts[:id])
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
        blob = @client.load(:blobs, opts[:id])
        return false unless blob
        blob[:user_metadata] = BlobHelper::rename_metadata_headers(opts['meta_hash'], '')
        @client.store(:blobs, blob)
      end
    end

    #--
    # Metrics
    #--
    def metrics(credentials, opts={})
      check_credentials( credentials )
      instances = @client.build_all(Instance)
      instances = filter_on( instances, :id, opts )

      metrics_arr = instances.collect do |instance|
        Metric.new(
          :id     => instance.id,
          :entity => instance.name
        )
      end

      # add metric names to metrics
      metrics_arr.each do |metric|
        @@METRIC_NAMES.each do |name|
          metric.add_property(name)
        end
        metric.properties.sort! {|a,b| a.name <=> b.name}
      end
      metrics_arr
    end

    def metric(credentials, opts={})
      metric = metrics(credentials, opts).first

      metric.properties.each do |property|

        property.values = (0..5).collect do |i|

          unit = metric_unit_for(property.name)
          average = (property.name == 'cpuUtilization') ? (rand * 1000).to_i / 10.0 : rand(1000)
          max = (property.name == 'cpuUtilization') ? (1000 + 10 * average).to_i / 20.0 : average * (i + 1)
          min = (property.name == 'cpuUtilization') ? (2.5 * average).to_i / 10.0 : (average / 4).to_i
          {
            :minimum   => min,
            :maximum   => max,
            :average   => average,
            :timestamp => Time.now - i * 60,
            :unit      => unit
          }
        end
      end
      metric
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

    #Mock allocation of 'new' address
    #There is a synchronization problem (but it's the mock driver,
    #mutex seemed overkill)
    def allocate_mock_address
      addresses = []
      @client.members(:addresses).each do |addr|
        addresses << IPAddr.new("#{addr}").to_i
      end
      IPAddr.new(addresses.sort.pop+1, Socket::AF_INET)
    end

    def attach_volume_instance(volume_id, device, instance_id)
      volume = @client.load(:storage_volumes, volume_id)
      instance = @client.load(:instances, instance_id)
      volume[:instance_id] = instance_id
      volume[:device] = device
      volume[:state] = "IN-USE"
      instance[:storage_volumes] ||= []
      instance[:storage_volumes] << {volume_id=>device}
      @client.store(:storage_volumes, volume)
      @client.store(:instances, instance)
      StorageVolume.new(volume)
    end

    def detach_volume_instance(volume_id, instance_id)
      volume = @client.load(:storage_volumes, volume_id)
      instance = @client.load(:instances, instance_id)
      volume[:instance_id] = nil
      device = volume[:device]
      volume[:device] = nil
      volume[:state] = "AVAILABLE"
      instance[:storage_volumes].delete({volume_id => device}) unless instance[:storage_volumes].nil?
      @client.store(:storage_volumes, volume)
      @client.store(:instances, instance)
      StorageVolume.new(volume)
    end

    def metric_unit_for(name)
      case name
        when /Utilization/ then 'Percent'
        when /Byte/ then 'Bytes'
        when /Sector/ then 'Count'
        when /Count/ then 'Count'
        when /Packet/ then 'Count'
        else 'None'
      end
    end

    # names copied from FGCP driver
    @@METRIC_NAMES = [
      'cpuUtilization',
      'diskReadRequestCount',
      'diskReadSector',
      'diskWriteRequestCount',
      'diskWriteSector',
      'nicInputByte',
      'nicInputPacket',
      'nicOutputByte',
      'nicOutputPacket'
    ]

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

      on /AddressInUse/ do
        status 403
      end

      on /AddressNotInUse/ do
        status 403
      end

      on /BucketNotExist/ do
        status 404
      end

      on /CreateImageNotSupported/ do
        status 500
      end

      on /NotExistentBlob/ do
        status 500
        message "Could not delete a non existent blob"
      end

      on /DeltacloudErrorTest/ do
        status 500
        message "DeltacloudErrorMessage"
      end

      on /NotImplementedTest/ do
        status 501
        message "NotImplementedMessage"
      end

      on /ProviderErrorTest/ do
        status 502
        message "ProviderErrorMessage"
      end

      on /ProviderTimeoutTest/ do
        status 504
        message "ProviderTimeoutMessage"
      end

    end

  end

end
