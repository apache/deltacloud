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

require 'ipaddr'

require_relative 'mock_client'
require_relative 'mock_driver_cimi_methods'

require_relative '../../runner'

module Deltacloud::Drivers::Mock

  class MockDriver < Deltacloud::BaseDriver

    define_hardware_profile('m1-small') do
      cpu              1
      memory         1.7 * 1024
      storage        160
      architecture 'i386'
    end

    define_hardware_profile('m1-large') do
      cpu              1..6
      memory           7680..(15*1024), :default => 10 * 1024
      storage          [ 850, 1024 ]
      architecture     'x86_64'
    end

    define_hardware_profile('m1-xlarge') do
      cpu              4
      memory           12*1024..32*1024
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

    feature :instances,
      :user_name,
      :user_Data,
      :authentication_key,
      :metrics,
      :realm_filter

    feature :images,
      :user_name,
      :user_description

    #cimi features
    feature :machines, :default_initial_state do
      { :values => ["STARTED"] }
    end
    feature :machines, :initial_states do
      { :values => ["STARTED", "STOPPED"]}
    end


    def initialize
      @client = Client.new(MOCK_STORAGE_DIR)
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
        results = [
          Realm.new(
            :id=>'us',
            :name=>'United States',
            :limit=>:unlimited,
            :state=>'AVAILABLE'
          ),
          Realm.new(
            :id=>'eu',
            :name=>'Europe',
            :limit=>:unlimited,
            :state=>'AVAILABLE'
          ),
        ]
      end
      results = filter_on( results, opts, :id )
      results
    end

    def filter_by_owner(credentials, images, owner_id)
      return images unless owner_id
      if owner_id == 'self'
        images.select { |e| e.owner_id == credentials.user }
      else
        filter_on(images, { :owner_id => owner_id}, :owner_id )
      end
    end

    #
    # Images
    #
    def images(credentials, opts={})
      check_credentials(credentials)
      images = @client.build_all(Image)

      images = filter_on(images, opts, :id, :architecture)
      images = filter_by_owner(credentials, images, opts[:owner_id])

      # Add hardware profiles to each image
      images = images.map { |i| (i.hardware_profiles = hardware_profiles(nil)) && i }

      images.sort_by{|e| [e.owner_id, e.description]}
    end

    def create_image(credentials, opts={})
      check_credentials(credentials)

      instance = instance(credentials, opts)

      safely do
        raise 'NotFound' unless instance
        raise 'CreateImageNotSupported' unless instance.can_create_image?
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
      if instance = @client.load_collection(:instances, opts[:id])
        Instance.new(instance)
      end
    end

    def instances(credentials, opts={})
      check_credentials( credentials )
      instances = @client.build_all(Instance)
      opts.merge!( :owner_id => credentials.user ) unless opts.has_key?(:owner_id)
      filter_on(instances, opts, :owner_id, :id, :state, :realm_id)
    end

    def generate_instance_id
      ids = @client.members(:instances)
      count, next_id = 0, ''
      loop do
        break unless ids.include?(next_id = "inst#{count}")
        count = count + 1
      end
      next_id
    end

    def create_instance(credentials, image_id, opts={})
      check_credentials( credentials )

      instance_id = generate_instance_id
      realm_id = opts[:realm_id] || realms(credentials).first.id

      if opts[:hwp_id]
        hwp = find_hardware_profile(credentials, opts[:hwp_id], image_id)
      else
        hwp = find_hardware_profile(credentials, 'm1-small', image_id)
      end

      name = opts[:name] || "i-#{Time.now.to_i}"

      initial_state = opts[:initial_state] || "RUNNING"

      instance = {
        :id => instance_id,
        :name => name,
        :state => (initial_state == "STARTED" ? "RUNNING" : initial_state),
        :keyname => opts[:keyname],
        :image_id => image_id,
        :owner_id => credentials.user,
        :public_addresses => [
          InstanceAddress.new("#{image_id}.#{instance_id}.public.com", :type => :hostname)
        ],
        :private_addresses =>[
          InstanceAddress.new("#{image_id}.#{instance_id}.private.com", :type => :hostname)
        ],
        :instance_profile => InstanceProfile.new(hwp.name, opts),
        :realm_id => realm_id,
        :create_image => true,
        :actions => instance_actions_for((initial_state == "STARTED" ? "RUNNING" : initial_state)),
        :user_data => opts[:user_data] ? Base64::decode64(opts[:user_data]) : nil
      }
      @client.store(:instances, instance)
      Instance.new( instance )
    end

    def update_instance_state(credentials, id, state)
      instance  = @client.load_collection(:instances, id)
      Instance.new(@client.store(:instances, instance.merge(
        :state => state,
        :actions => instance_actions_for(state)
      )))
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
      #also destroy the instance network_interface(s) if any:
      inst = @client.load_collection(:instances, id)
      inst[:network_interfaces].each do |network_interface|
        destroy_network_interface(credentials, network_interface)
      end if inst[:network_interfaces]
      @client.destroy(:instances, id)
    end

    # mock object to mimick Net::SSH object
    class MockSSH
      attr_accessor :command
    end

    def run_on_instance(credentials, opts={})
      ssh = MockSSH.new
      ssh.command = opts[:cmd]
      Deltacloud::Runner::Response.new(
        ssh,
        "This is where the output from '#{ssh.command}' would appear if this were not a mock provider"
      )
    end

    #
    # Storage Volumes
    #
    def storage_volumes(credentials, opts={})
      check_credentials(credentials)
      filter_on(@client.build_all(StorageVolume), opts, :id)
    end

    def create_storage_volume(credentials, opts={})
      check_credentials(credentials)
      opts[:capacity] ||= "1"
      volume_id = "volume_#{Time.now.to_i}"
      volume = @client.store(:storage_volumes, {
        :id => volume_id,
        :name => opts[:name] ? opts[:name] : "Volume#{volume_id}",
        :created => Time.now.to_s,
        :state => "AVAILABLE",
        :capacity => opts[:capacity],
      })
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

    def detach_storage_volume(credentials, opts={})
      check_credentials(credentials)
      detach_volume_instance(opts[:id], opts[:instance_id])
    end

    #
    # Storage Snapshots
    #

    def storage_snapshots(credentials, opts={})
      check_credentials( credentials )
      filter_on(@client.build_all(StorageSnapshot), opts, :id)
    end

    def create_storage_snapshot(credentials, opts={})
      check_credentials(credentials)
      id = "store_snapshot_#{Time.now.to_i}"
      snapshot = {
            :id => id,
            :created => Time.now.to_s,
            :state => "COMPLETED",
            :storage_volume_id => opts[:volume_id],
      }
      snapshot.merge!({:name => opts[:name]}) if opts[:name]
      snapshot.merge!({:description => opts[:description]}) if opts[:description]
      StorageSnapshot.new(@client.store(:storage_snapshots, snapshot))
    end

    def destroy_storage_snapshot(credentials, opts={})
      check_credentials(credentials)
      @client.destroy(:storage_snapshots, opts[:id])
    end

    def keys(credentials, opts={})
      check_credentials(credentials)
      filter_on(@client.build_all(Key), opts, :id)
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
        raise "KeyExist" if @client.load_collection(:keys, key_hash[:id])
        Key.new(@client.store(:keys, key_hash))
      end
    end

    def destroy_key(credentials, opts={})
      key = key(credentials, opts)
      @client.destroy(:keys, key.id)
    end

    def addresses(credentials, opts={})
      check_credentials(credentials)
      filter_on(@client.build_all(Address), opts, :id)
    end

    def create_address(credentials, opts={})
      check_credentials(credentials)
      Address.new(@client.store(:addresses, {
        :id => allocate_mock_address.to_s,
        :instance_id => nil
      }))
    end

    def destroy_address(credentials, opts={})
      check_credentials(credentials)
      address = @client.load_collection(:addresses, opts[:id])
      raise "AddressInUse" unless address[:instance_id].nil?
      @client.destroy(:addresses, opts[:id])
    end

    def associate_address(credentials, opts={})
      check_credentials(credentials)
      address = @client.load_collection(:addresses, opts[:id])
      raise "AddressInUse" unless address[:instance_id].nil?
      instance = @client.load_collection(:instances, opts[:instance_id])
      address[:instance_id] = instance[:id]
      instance[:public_addresses] = [InstanceAddress.new(address[:id])]
      @client.store(:addresses, address)
      @client.store(:instances, instance)
    end

    def disassociate_address(credentials, opts={})
      check_credentials(credentials)
      address = @client.load_collection(:addresses, opts[:id])
      raise "AddressNotInUse" unless address[:instance_id]
      instance = @client.load_collection(:instances, address[:instance_id])
      address[:instance_id] = nil
      instance[:public_addresses] = [
        InstanceAddress.new("#{instance[:image_id]}.#{instance[:id]}.public.com", :type => :hostname)
      ]
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
      filter_on( buckets, opts, :id)
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
      opts.merge!( :bucket => opts.delete('bucket') )
      filter_on(blobs, opts, :id, :bucket)
    end

    #--
    # Blob content
    #--
    def blob_data(credentials, bucket_id, blob_id, opts = {})
      check_credentials(credentials)
      if blob = @client.load_collection(:blobs, blob_id)
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
      update_bucket_size(bucket_id, :plus)
      Blob.new(@client.store(:blobs, blob))
    end

    #--
    # Delete blob
    #--
    def delete_blob(credentials, bucket_id, blob_id, opts={})
      check_credentials(credentials)
      safely do
        raise "NotExistentBlob" unless @client.load_collection(:blobs, blob_id)
        update_bucket_size(bucket_id, :minus)
        @client.destroy(:blobs, blob_id)
      end
    end

    #--
    # Get metadata
    #--
    def blob_metadata(credentials, opts={})
      check_credentials(credentials)
      (blob = @client.load_collection(:blobs, opts[:id])) ? blob[:user_metadata] : nil
    end

    #--
    # Update metadata
    #--
    def update_blob_metadata(credentials, opts={})
      check_credentials(credentials)
      safely do
        if blob = @client.load_collection(:blobs, opts[:id])
          @client.store(:blobs, blob.merge(
            :user_metadata => BlobHelper::rename_metadata_headers(opts['meta_hash'], '')
          ))
        else
          false
        end
      end
    end

    #--
    # Metrics
    #--
    def metrics(credentials, opts={})
      check_credentials(credentials)
      instances(credentials).map do |inst|
        metric = Metric.new(
          :id     => inst.id,
          :entity => inst.name
        )
        Metric::MOCK_METRICS_NAMES.each { |metric_name| metric.add_property(metric_name) }
        metric.properties.sort! { |a,b| a.name <=> b.name }
        metric
      end
    end

    def metric(credentials, opts={})
      metric = metrics(credentials).first
      metric.properties.each { |p| p.generate_mock_values! }
      metric
    end

    def networks(credentials, opts={})
      check_credentials(credentials)
      networks = @client.build_all(Network)
      filter_on(networks, opts, :id)
    end

    def create_network(credentials, opts={})
      check_credentials(credentials)
      id = opts[:name] || "net_#{Time.now.to_i}"
      net_hash = { :id => id,
                   :name => id,
                   :address_blocks => [opts[:address_block]],
                   :state => "UP"}
      @client.store(:networks, net_hash)
      Network.new(net_hash)
    end

    def destroy_network(credentials, network_id)
      check_credentials(credentials)
      net = network(credentials, {:id => network_id})
      #also destroy subnets:
      net.subnets.each do |sn|
        destroy_subnet(credentials, sn)
      end
      @client.destroy(:networks, network_id)
    end

    def subnets(credentials, opts={})
      check_credentials(credentials)
      subnets = @client.build_all(Subnet)
      filter_on(subnets, opts, :id)
    end

    def create_subnet(credentials, opts={})
      check_credentials(credentials)
      id = opts[:name] || "subnet_#{Time.now.to_i}"
      snet_hash = { :id => id,
                   :name => id,
                   :address_block => opts[:address_block],
                   :network => opts[:network_id],
                   :state => "UP"}
      @client.store(:subnets, snet_hash)
      #also update network:
      net = @client.load_collection(:networks, opts[:network_id])
      net[:subnets] ||=[]
      net[:subnets]  << snet_hash[:id]
      @client.store(:networks, net)
      Subnet.new(snet_hash)
    end

    def destroy_subnet(credentials, subnet_id)
      check_credentials(credentials)
      snet = subnet(credentials, {:id => subnet_id})
      #also update network:
      net = @client.load_collection(:networks, snet.network)
      net[:subnets].delete(subnet_id)
      @client.store(:networks, net)
      @client.destroy(:subnets, subnet_id)
    end

    def network_interfaces(credentials, opts={})
      check_credentials(credentials)
      network_interfaces = @client.build_all(NetworkInterface)
      filter_on(network_interfaces, opts, :id)
    end

    def create_network_interface(credentials, opts={})
      check_credentials(credentials)
      id = opts[:name] || "nic_#{Time.now.to_i}"
      nic_hash = {:id => id, :name => id, :instance => opts[:instance],
                  :network => opts[:network]}
      #need an IP address from the subnet cidr range:
      snet = @client.load_collection(:subnets,  opts[:subnet])
      cidr = IPAddr.new(snet[:address_block])
      nic_hash[:ip_address] = cidr.to_range.to_a.sample.to_s #sloppy, choose random address - hey it's mock!
      #need to update instance nics:
      inst = @client.load_collection(:instances, opts[:instance])
      inst[:network_interfaces] ||= []
      inst[:network_interfaces] << id
      @client.store(:instances, inst)
      @client.store(:network_interfaces, nic_hash)
      NetworkInterface.new(nic_hash)
    end

    def destroy_network_interface(credentials, nic_id)
      check_credentials(credentials)
      #need to update the instance too
      nic = @client.load_collection(:network_interfaces, nic_id)
      inst = @client.load_collection(:instances, nic[:instance])
      inst[:network_interfaces].delete(nic_id)
      @client.store(:instances, inst)
      @client.destroy(:network_interfaces, nic_id)
    end

    private

    def check_credentials(credentials)
      safely do
        if ( credentials.user != 'mockuser' ) or ( credentials.password != 'mockpassword' )
          raise 'AuthFailure'
        end
      end
    end
    alias :new_client :check_credentials

    # Mock allocation of 'new' address
    # There is a synchronization problem (but it's the mock driver,
    # mutex seemed overkill)
    #
    def allocate_mock_address
      addresses = []
      @client.members(:addresses).each do |addr|
        addresses << IPAddr.new("#{addr}").to_i
      end
      IPAddr.new(addresses.sort.pop+1, Socket::AF_INET)
    end

    def attach_volume_instance(volume_id, device, instance_id)
      volume = @client.load_collection(:storage_volumes, volume_id)
      instance = @client.load_collection(:instances, instance_id)
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
      volume = @client.load_collection(:storage_volumes, volume_id)
      instance = @client.load_collection(:instances, instance_id)
      volume[:instance_id] = nil
      device = volume[:device]
      volume[:device] = nil
      volume[:state] = "AVAILABLE"
      instance[:storage_volumes].delete({volume_id => device}) unless instance[:storage_volumes].nil?
      @client.store(:storage_volumes, volume)
      @client.store(:instances, instance)
      StorageVolume.new(volume)
    end

    def update_bucket_size(id, change)
      bucket = @client.load_collection(:buckets, id)
      raise 'BucketNotExist' if bucket.nil?
      bucket[:size] = case change
        when :plus then bucket[:size].to_i + 1
        when :minus then  bucket[:size].to_i - 1
        else
          raise "unkown update operation for bucket!"
      end
      @client.store(:buckets, bucket)
    end

    exceptions do

      on /AuthFailure/ do
        status 401
        message "Authentication Failure"
      end

      on /CreateImageNotSupported/ do
        status 500
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

      on /(BucketNotExist|NotFound)/ do
        status 404
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
