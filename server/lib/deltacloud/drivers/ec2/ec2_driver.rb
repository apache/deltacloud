#
# Copyright (C) 2009  Red Hat, Inc.
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
require 'active_support'
require 'AWS'
require 'right_aws'

class Instance
  attr_accessor :keyname
  attr_accessor :authn_error

  def authn_feature_failed?
    return true unless authn_error.nil?
  end

end

module Deltacloud
  module Drivers
    module EC2
class EC2Driver < Deltacloud::BaseDriver

  def supported_collections
    DEFAULT_COLLECTIONS + [ :keys, :buckets ]
  end

  feature :instances, :user_data
  feature :instances, :authentication_key
  feature :images, :owner_id
  feature :buckets, :bucket_location

  define_hardware_profile('m1.small') do
    cpu                1
    memory             1.7 * 1024
    storage            160
    architecture       'i386'
  end

  define_hardware_profile('m1.large') do
    cpu                4
    memory             7.5 * 1024
    storage            850
    architecture       'x86_64'
  end

  define_hardware_profile('m1.xlarge') do
    cpu                8
    memory             15 * 1024
    storage            1690
    architecture       'x86_64'
  end

  define_hardware_profile('c1.medium') do
    cpu                5
    memory             1.7 * 1024
    storage            350
    architecture       'i386'
  end

  define_hardware_profile('c1.xlarge') do
    cpu                20
    memory             7 * 1024
    storage            1690
    architecture       'x86_64'
  end

  define_hardware_profile('m2.xlarge') do
    cpu                6.5
    memory             17.1 * 1024
    storage            420
    architecture       'x86_64'
  end

  define_hardware_profile('m2.2xlarge') do
    cpu                13
    memory             34.2 * 1024
    storage            850
    architecture       'x86_64'
  end

  define_hardware_profile('m2.4xlarge') do
    cpu                26
    memory             68.4 * 1024
    storage            1690
    architecture       'x86_64'
  end

  define_instance_states do
    start.to( :pending )          .automatically
    pending.to( :running )        .automatically
    pending.to( :stopping )       .on( :stop )
    pending.to( :stopped )        .automatically
    stopped.to( :running )        .on( :start )
    running.to( :running )        .on( :reboot )
    running.to( :stopping )       .on( :stop )
    shutting_down.to( :stopped )  .automatically
    stopped.to( :finish )         .automatically
  end

  #
  # Images
  #

  def images(credentials, opts={} )
    ec2 = new_client(credentials)
    img_arr = []
    # if we know the image_id, we don't want to limit by owner_id, since this
    # will exclude public images
    if (opts and opts[:id])
      config = { :image_id => opts[:id] }
    else
      config = { :owner_id => "amazon" }
      config.merge!({ :owner_id => opts[:owner_id] }) if opts and opts[:owner_id]
    end
    safely do
      ec2.describe_images(config).imagesSet.item.each do |image|
        img_arr << convert_image(image)
      end
    end
    img_arr = filter_on( img_arr, :architecture, opts )
    img_arr.sort_by{|e| [e.owner_id, e.name]}
  end

  #
  # Realms
  #

  def realms(credentials, opts=nil)
    ec2 = new_client(credentials)
    realms = []
    safely do
      ec2.describe_availability_zones.availabilityZoneInfo.item.each do |ec2_realm|
        realms << convert_realm( ec2_realm )
      end
    end
    realms
  end

  #
  # Instances
  #
  def instances(credentials, opts=nil)
    ec2 = new_client(credentials)
    instances = []
    safely do
      param = opts.nil? ? nil : opts[:id]
      ec2_instances = ec2.describe_instances.reservationSet
      return [] unless ec2_instances
      ec2_instances.item.each do |item|
        item.instancesSet.item.each do |ec2_instance|
          instances << convert_instance( ec2_instance, item.ownerId )
        end
      end
    end
    instances = filter_on( instances, :id, opts )
    instances = filter_on( instances, :state, opts )
    instances
  end


  def create_instance(credentials, image_id, opts)
    ec2 = new_client( credentials )
    realm_id = opts[:realm_id]
    safely do
      image = image(credentials, :id => image_id )
      hwp = find_hardware_profile(credentials, opts[:hwp_id], image.id)
      ec2_instances = ec2.run_instances(
        :image_id => image.id,
        :user_data => opts[:user_data],
        :key_name => opts[:keyname],
        :availability_zone => realm_id,
        :monitoring_enabled => true,
        :instance_type => hwp.name,
        :disable_api_termination => false,
        :instance_initiated_shutdown_behavior => 'terminate'
      )
      return convert_instance( ec2_instances.instancesSet.item.first, 'pending' )
    end
  end

  def generate_instance(ec2, id, backup)
    begin
      this_instance = ec2.describe_instances( :instance_id => id ).reservationSet.item.first.instancesSet.item.first
      convert_instance(this_instance, this_instance.ownerId)
    rescue Exception => e
      puts "WARNING: ignored error during instance refresh: #{e.message}"
      # at this point, the action has succeeded but our follow-up
      # "describe_instances" failed for some reason.  Create a simple Instance
      # object with only the ID and new state in place
      state = convert_state(backup.instancesSet.item.first.currentState.name)
      Instance.new( {
        :id => id,
        :state => state,
        :actions => instance_actions_for( state ),
      } )
    end
  end

  def reboot_instance(credentials, id)
    ec2 = new_client(credentials)
    backup = ec2.reboot_instances( :instance_id => id )

    generate_instance(ec2, id, backup)
  end

  def stop_instance(credentials, id)
    ec2 = new_client(credentials)
    backup = ec2.terminate_instances( :instance_id => id )

    generate_instance(ec2, id, backup)
  end

  def destroy_instance(credentials, id)
    ec2 = new_client(credentials)
    backup = ec2.terminate_instances( :instance_id => id )

    generate_instance(ec2, id, backup)
  end

  #
  # Storage Volumes
  #

  def storage_volumes(credentials, opts=nil)
    ec2 = new_client( credentials )
    volumes = []
    safely do
      if (opts)
        ec2.describe_volumes(:volume_id => opts[:id]).volumeSet.item.each do |ec2_volume|
          volumes << convert_volume( ec2_volume )
        end
      else
        ec2_volumes = ec2.describe_volumes.volumeSet
        return [] unless ec2_volumes
        ec2_volumes.item.each do |ec2_volume|
          volumes << convert_volume( ec2_volume )
        end
      end
    end
    volumes
  end

  #
  # Storage Snapshots
  #

  def storage_snapshots(credentials, opts=nil)
    ec2 = new_client( credentials )
    snapshots = []
    safely do
      if (opts)
        ec2.describe_snapshots(:owner => 'self', :snapshot_id => opts[:id]).snapshotSet.item.each do |ec2_snapshot|
          snapshots << convert_snapshot( ec2_snapshot )
        end
      else
        ec2_snapshots = ec2.describe_snapshots(:owner => 'self').snapshotSet
        return [] unless ec2_snapshots
        ec2_snapshots.item.each do |ec2_snapshot|
          snapshots << convert_snapshot( ec2_snapshot )
        end
      end
    end
    snapshots
  end

  def key(credentials, opts=nil)
    keys(credentials, opts).first
  end

  def keys(credentials, opts=nil)
    ec2 = new_client( credentials )
    opts[:key_name] = opts[:id] if opts and opts[:id]
    keypairs = ec2.describe_keypairs(opts || {})
    result = []
    safely do
      keypairs.keySet.item.each do |keypair|
        result << convert_key(keypair)
      end
    end
    result
  end

  def create_key(credentials, opts={})
    key = Key.new
    ec2 = new_client( credentials )
    safely do
      key = convert_key(ec2.create_keypair(opts))
    end
    return key
  end

  def destroy_key(credentials, opts={})
    safely do
      ec2 = new_client( credentials )
      ec2.delete_keypair(opts)
    end
  end

  def valid_credentials?(credentials)
    client = new_client(credentials)
    # FIXME: We need to do this call to determine if
    #        EC2 is working with given credentials. There is no
    #        other way to check, if given credentials are valid or not.
    realms = client.describe_availability_zones rescue false
    return realms ? true : false
  end

#--
# Buckets
#-- get a list of your buckets from the s3 service
  def buckets(credentials, opts)
    buckets = []
    safely do
      s3_client = s3_client(credentials)
      bucket_list = s3_client.buckets
      bucket_list.each do |current|
        buckets << convert_bucket(current)
      end
    end
    buckets = filter_on(buckets, :id, opts)
    buckets
  end

#--
# Create bucket
#--
#valid values for bucket location: 'EU'|'us-west1'|'ap-southeast-1' - if you
#don't specify a location then by default buckets are created in 'us-east'
#[but if you *do* specify 'us-east' things blow up]
  def create_bucket(credentials, name, opts={})
    bucket = nil
    safely do
      begin
        s3_client = s3_client(credentials)
        bucket_location = opts['location']
        if bucket_location
          bucket = RightAws::S3::Bucket.create(s3_client, name, true, nil, :location => bucket_location)
        else
          bucket = RightAws::S3::Bucket.create(s3_client, name, true)
        end #if
        rescue RightAws::AwsError => e
          raise e unless e.message =~ /BucketAlreadyExists/
          raise Deltacloud::BackendError.new(409, e.class.to_s, e.message, e.backtrace)
      end #begin
    end #do
    convert_bucket(bucket)
  end

#--
# Delete_bucket
#--
  def delete_bucket(credentials, name, opts={})
    s3_client = s3_client(credentials)
    safely do
      s3_client.interface.delete_bucket(name)
    end
  end

#--
# Blobs
#--
  def blobs(credentials, opts = nil)
    s3_client = s3_client(credentials)
    blobs = []
    safely do
      s3_bucket = s3_client.bucket(opts['bucket'])
      s3_bucket.keys({}, true).each do |s3_object|
        blobs << convert_object(s3_object)
      end
    end
    blobs = filter_on(blobs, :id, opts)
    blobs
  end

#--
# Blob data
#--
  def blob_data(credentials, bucket_id, blob_id, opts)
    s3_client = s3_client(credentials)
    s3_client.interface.get(bucket_id, blob_id) do |chunk|
      yield chunk
    end
  end

  private

  def new_client(credentials)
    opts = {
      :access_key_id => credentials.user,
      :secret_access_key => credentials.password
    }
    opts[:server] = ENV['DCLOUD_EC2_URL'] if ENV['DCLOUD_EC2_URL']
    safely do
      AWS::EC2::Base.new(opts)
    end
  end

  def convert_key(key)
    Key.new({
      :id => key['keyName'],
      :fingerprint => key['keyFingerprint'],
      :credential_type => :key,
      :pem_rsa_key => key['keyMaterial']
    })
  end

  def convert_image(ec2_image)
    Image.new( {
      :id=>ec2_image['imageId'],
      :name=>ec2_image['name'] || ec2_image['imageId'],
      :description=>ec2_image['description'] || ec2_image['imageLocation'] || '',
      :owner_id=>ec2_image['imageOwnerId'],
      :architecture=>ec2_image['architecture'],
    } )
  end

  def convert_realm(ec2_realm)
    Realm.new( {
      :id=>ec2_realm['zoneName'],
      :name=>ec2_realm['regionName'],
      :limit=>ec2_realm['zoneState'].eql?('available') ? :unlimited : 0,
      :state=>ec2_realm['zoneState'].upcase,
    } )
  end

  def convert_state(ec2_state)
    case ec2_state
    when "terminated"
      "STOPPED"
    when "stopped"
      "STOPPED"
    when "running"
      "RUNNING"
    when "pending"
      "PENDING"
    when "shutting-down"
      "STOPPED"
    end
  end

  def convert_instance(ec2_instance, owner_id)
    state = convert_state(ec2_instance['instanceState']['name'])
    realm_id = ec2_instance['placement']['availabilityZone']
    (realm_id = nil ) if ( realm_id == '' )
    hwp_name = ec2_instance['instanceType']
    instance = Instance.new( {
      :id=>ec2_instance['instanceId'],
      :name => ec2_instance['imageId'],
      :state=>state,
      :image_id=>ec2_instance['imageId'],
      :owner_id=>owner_id,
      :realm_id=>realm_id,
      :public_addresses=>( ec2_instance['dnsName'] == '' ? [] : [ec2_instance['dnsName']] ),
      :private_addresses=>( ec2_instance['privateDnsName'] == '' ? [] : [ec2_instance['privateDnsName']] ),
      :instance_profile =>InstanceProfile.new(hwp_name),
      :actions=>instance_actions_for( state ),
      :keyname => ec2_instance['keyName'],
      :launch_time => ec2_instance['launchTime']
    } )
    instance.authn_error = "Key not set for instance" unless ec2_instance['keyName']
    return instance
  end

  def convert_volume(ec2_volume)
    StorageVolume.new( {
      :id=>ec2_volume['volumeId'],
      :created=>ec2_volume['createTime'],
      :state=>ec2_volume['status'].upcase,
      :capacity=>ec2_volume['size'],
      :instance_id=>ec2_volume['snapshotId'],
      :device=>ec2_volume['attachmentSet'],
    } )
  end

  def convert_snapshot(ec2_snapshot)
    StorageSnapshot.new( {
      :id=>ec2_snapshot['snapshotId'],
      :state=>ec2_snapshot['status'].upcase,
      :storage_volume_id=>ec2_snapshot['volumeId'],
      :created=>ec2_snapshot['startTime'],
    } )
  end

  def s3_client(credentials)
    safely do
      s3_client = RightAws::S3.new(credentials.user, credentials.password)
    end
  end

  def convert_bucket(s3_bucket)
    #get blob list:
    blob_list = []
    s3_bucket.keys.each do |s3_object|
      blob_list << s3_object.name
    end
    #can use AWS::S3::Owner.current.display_name or current.id
    Bucket.new(  { :id => s3_bucket.name,
                      :name => s3_bucket.name,
                      :size => s3_bucket.keys.length,
                      :blob_list => blob_list
                    }
                 )
  end

  def convert_object(s3_object)
    Blob.new({   :id => s3_object.name,
                 :bucket => s3_object.bucket.name.to_s,
                 :content_length => s3_object.size,
                 :content_type => s3_object.content_type,
                 :last_modified => s3_object.last_modified
              })
  end

  def catched_exceptions_list
    {
      :auth => [ AWS::AuthFailure ],
      :error => [],
      :glob => [ /AWS::(\w+)/ ]
    }
  end

end

    end
  end
end
