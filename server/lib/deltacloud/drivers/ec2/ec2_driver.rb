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
#

require 'deltacloud/base_driver'
require 'aws'

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
        feature :instances, :public_ip
        feature :instances, :security_group
        feature :images, :owner_id
        feature :buckets, :bucket_location

        define_hardware_profile('t1.micro') do
          cpu                1
          memory             0.63 * 1024
          storage            160
          architecture       'i386'
        end

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

        def images(credentials, opts={})
          ec2 = new_client(credentials)
          img_arr = []
          opts ||= {}
          if opts[:id]
            safely do
              img_arr = ec2.describe_images(opts[:id]).collect do |image|
                convert_image(image)
              end
            end
          else
            owner_id = opts[:owner_id] || "amazon"
            safely do
              img_arr = ec2.describe_images_by_owner(owner_id, "machine").collect do |image|
                convert_image(image)
              end
            end
          end
          img_arr = filter_on( img_arr, :architecture, opts )
          img_arr.sort_by { |e| [e.owner_id, e.name] }
        end

        def realms(credentials, opts={})
          ec2 = new_client(credentials)
          zone_id = opts ? opts[:id] : nil
          safely do
            return ec2.describe_availability_zones(zone_id).collect do |realm|
              convert_realm(realm)
            end
          end
        end

        def instances(credentials, opts={})
          ec2 = new_client(credentials)
          inst_arr = []
          safely do
            inst_arr = ec2.describe_instances.collect do |instance| 
              convert_instance(instance) if instance
            end.flatten
            tags = ec2.describe_tags(
              'Filter.1.Name' => 'resource-type', 'Filter.1.Value' => 'instance'
            )
            inst_arr.each do |inst|
              name_tag = tags.select { |t| (t[:aws_resource_id] == inst.id) and t[:aws_key] == 'name' }
              unless name_tag.empty?
                inst.name = name_tag.first[:aws_value]
              end
            end
            delete_unused_tags(credentials, inst_arr.collect {|inst| inst.id})
          end
          inst_arr = filter_on( inst_arr, :id, opts )
          filter_on( inst_arr, :state, opts )
        end

        def create_instance(credentials, image_id, opts={})
          ec2 = new_client(credentials)
          instance_options = {}
          instance_options.merge!(:user_data => opts[:user_data]) if opts[:user_data]
          instance_options.merge!(:key_name => opts[:key_name]) if opts[:key_name]
          instance_options.merge!(:availability_zone => opts[:availability_zone]) if opts[:availability_zone]
          instance_options.merge!(:instance_type => opts[:hwp_id]) if opts[:hwp_id]
          instance_options.merge!(:group_ids => opts[:security_group]) if opts[:security_group]
          safely do
            new_instance = convert_instance(ec2.launch_instances(image_id, instance_options).first)
            if opts[:public_ip]
              ec2.associate_address(new_instance.id, opts[:public_ip])
            end
            if opts[:name]
              tag_instance(credentials, new_instance, opts[:name])
            end
            new_instance
          end
        end
    
        def reboot_instance(credentials, instance_id)
          ec2 = new_client(credentials)
          if ec2.reboot_instances([instance_id])
            instance(credentials, instance_id)
          else
            raise Deltacloud::BackendError.new(500, "Instance", "Instance reboot failed", "")
          end
        end

        def destroy_instance(credentials, instance_id)
          ec2 = new_client(credentials)
          puts "Terminating instance #{instance_id}"
          instance_id = instance_id
          if ec2.terminate_instances([instance_id])
            untag_instance(credentials, instance_id)
            instance(credentials, instance_id)
          else
            raise Deltacloud::BackendError.new(500, "Instance", "Instance cannot be terminated", "")
          end
        end

        alias :stop_instance :destroy_instance

        def keys(credentials, opts={})
          ec2 = new_client(credentials)
          opts ||= {}
          safely do
            ec2.describe_key_pairs(opts[:id] || nil).collect do |key|
              convert_key(key)
            end
          end
        end

        def key(credentials, opts={})
          keys(credentials, :id => opts[:id]).first
        end

        def create_key(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            convert_key(ec2.create_key_pair(opts[:key_name]))
          end
        end

        def destroy_key(credentials, opts={})
          ec2 = new_client(credentials)
          original_key = key(credentials, opts)
          safely do
            ec2.delete_key_pair(original_key.id)
            original_key= original_key.state = "DELETED"
          end
          original_key
        end

        def buckets(credentials, opts)
          buckets = []
          safely do
            s3_client = new_client(credentials, :s3)
            bucket_list = s3_client.buckets
            bucket_list.each do |current|
              buckets << convert_bucket(current)
            end
          end
          filter_on(buckets, :id, opts)
        end

        def create_bucket(credentials, name, opts={})
          bucket = nil
          safely do
            s3_client = new_client(credentials, :s3)
            bucket_location = opts['location']
            if bucket_location
              bucket = Aws::S3::Bucket.create(s3_client, name, true, nil, :location => bucket_location)
            else
              bucket = Aws::S3::Bucket.create(s3_client, name, true)
            end
          end
          convert_bucket(bucket)
        end

        def delete_bucket(credentials, name, opts={})
          s3_client = new_client(credentials, :s3)
          safely do
            s3_client.interface.delete_bucket(name)
          end
        end

        def blobs(credentials, opts = nil)
          s3_client = new_client(credentials, :s3)
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
        # Create Blob
        #--
        def create_blob(credentials, bucket_id, blob_id, data = nil, opts = nil)
          s3_client = new_client(credentials, :s3)
          #data is a construct with the temporary file created by server @.tempfile
          #also file[:type] will give us the content-type
          res = nil
          # File stream needs to be reopened in binary mode for whatever reason
          file = File::open(data[:tempfile].path, 'rb')
          safely do
            res = s3_client.interface.put(bucket_id, 
                                        blob_id, 
                                        file, 
                                        {"Content-Type" => data[:type]})
          end
          #create a new Blob object and return that
          Blob.new( { :id => blob_id,
                      :bucket => bucket_id,
                      :content_length => data[:tempfile].length,
                      :content_type => data[:type],
                      :last_modified => ''
                    }
                  )
        end

        #--
        # Delete Blob
        #--  
        def delete_blob(credentials, bucket_id, blob_id, opts=nil)
          s3_client = new_client(credentials, :s3)
          s3_client.interface.delete(bucket_id, blob_id)
        end


        def blob_data(credentials, bucket_id, blob_id, opts)
          s3_client = new_client(credentials, :s3)
          s3_client.interface.get(bucket_id, blob_id) do |chunk|
            yield chunk
          end
        end

        def storage_volumes(credentials, opts={})
          ec2 = new_client( credentials )
          volume_list = (opts and opts[:id]) ? opts[:id] : nil
          safely do
            ec2.describe_volumes(volume_list).collect do |volume|
              convert_volume(volume)
            end
          end
        end

        def create_storage_volume(credentials, opts=nil)
          ec2 = new_client(credentials)
          opts ||= {}
          opts[:snapshot_id] ||= ""
          opts[:capacity] ||= "1"
          opts[:realm_id] ||= realms(credentials).first.id
          safely do
            convert_volume(ec2.create_volume(opts[:snapshot_id], opts[:capacity], opts[:realm_id]))
          end
        end

        def destroy_storage_volume(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            unless ec2.delete_volume(opts[:id]) 
              raise Deltacloud::BackendError.new(500, "StorageVolume", "Cannot delete storage volume")
            end
            storage_volume(credentials, opts[:id])
          end
        end

        def attach_storage_volume(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            convert_volume(ec2.attach_volume(opts[:id], opts[:instance_id], opts[:device]))
          end
        end

        def detach_storage_volume(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            convert_volume(ec2.detach_volume(opts[:id], opts[:instance_id], opts[:device], true))
          end
        end

        def storage_snapshots(credentials, opts={})
          ec2 = new_client(credentials)
          snapshot_list = (opts and opts[:id]) ? opts[:id] : []
          safely do
            ec2.describe_snapshots(snapshot_list).collect do |snapshot|
              convert_snapshot(snapshot)
            end
          end
        end

        def create_storage_snapshot(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            convert_snapshot(ec2.try_create_snapshot(opts[:volume_id]))
          end
        end

        def destroy_storage_snapshot(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            unless convert_snapshot(opts[:id])
              raise Deltacloud::BackendError.new(500, "StorageSnapshot", "Cannot destroy this snapshot")
            end
          end
        end

        private

        def new_client(credentials, type = :ec2)
          case type
            when :ec2 then Aws::Ec2.new(credentials.user, credentials.password)
            when :s3 then Aws::S3.new(credentials.user, credentials.password)
          end
        end

        def tag_instance(credentials, instance, name)
          ec2 = new_client(credentials)
          safely do
            ec2.create_tag(instance.id, 'name', name)
          end
        end

        def untag_instance(credentials, instance_id)
          ec2 = new_client(credentials)
          safely do
            ec2.delete_tag(instance_id, 'name')
          end
        end

        def delete_unused_tags(credentials, inst_ids)
          ec2 = new_client(credentials)
          tags = []
          safely do
            tags = ec2.describe_tags('Filter.1.Name' => 'resource-type', 'Filter.1.Value' => 'instance')
            tags.collect! { |t| t[:aws_resource_id] }
            inst_ids.each do |inst_id|
              unless tags.include?(inst_id)
                ec2.delete_tag(inst_id, 'name')
              end
            end
          end
        end
        
        def convert_bucket(s3_bucket)
          #get blob list:
          blob_list = []
          s3_bucket.keys.each do |s3_object|
            blob_list << s3_object.name
          end
          #can use AWS::S3::Owner.current.display_name or current.id
          Bucket.new(
            :id => s3_bucket.name,
            :name => s3_bucket.name,
            :size => s3_bucket.keys.length,
            :blob_list => blob_list
          )
        end

        def convert_realm(realm)
          Realm.new(
            :id => realm[:zone_name],
            :name => realm[:zone_name],
            :state => realm[:zone_state],
            :limit => realm[:zone_state].eql?('available') ? :unlimited : 0
          )
        end

        def convert_image(image)
          # There is not support for 'name' for now
          Image.new(
            :id => image[:aws_id],
            :name => image[:aws_name] || image[:aws_id],
            :description => image[:aws_description] || image[:aws_location],
            :owner_id => image[:aws_owner],
            :architecture => image[:aws_architecture],
            :state => image[:state]
          )
        end

        def convert_instance(instance)
          Instance.new(
            :id => instance[:aws_instance_id],
            :name => instance[:aws_image_id],
            :state => convert_state(instance[:aws_state]),
            :image_id => instance[:aws_image_id],
            :owner_id => instance[:aws_owner],
            :actions => instance_actions_for(convert_state(instance[:aws_state])),
            :key_name => instance[:ssh_key_name],
            :launch_time => instance[:aws_launch_time],
            :instance_profile => InstanceProfile.new(instance[:aws_instance_type]),
            :realm_id => instance[:aws_availability_zone],
            :private_addresses => instance[:private_dns_name],
            :public_addresses => instance[:public_addresses]
          )
        end

        def convert_key(key)
          Key.new(
            :id => key[:aws_key_name],
            :fingerprint => key[:aws_fingerprint],
            :credential_type => :key,
            :pem_rsa_key => key[:aws_material],
            :state => "AVAILABLE"
          )
        end

        def convert_volume(volume)
          StorageVolume.new(
            :id => volume[:aws_id],
            :created => volume[:aws_created_at],
            :state => volume[:aws_status] ? volume[:aws_status].upcase : 'unknown',
            :capacity => volume[:aws_size],
            :instance_id => volume[:aws_instance_id],
            :realm_id => volume[:zone],
            :device => volume[:aws_device],
            # TODO: the available actions should be tied to the current
            # volume state                
            :actions => [:attach, :detach, :destroy] 
          )
        end

        def convert_snapshot(snapshot)
          StorageSnapshot.new(
            :id => snapshot[:aws_id],
            :state => snapshot[:aws_status],
            :storage_volume_id => snapshot[:aws_volume_id],
            :created => snapshot[:aws_started_at]
          )
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

        def catched_exceptions_list
          {
            :auth => [], # [ ::Aws::AuthFailure ],
            :error => [ ::Aws::AwsError ],
            :glob => [ /AWS::(\w+)/ ]
          }
        end

      end
    end
  end
end
