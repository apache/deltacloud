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

require 'aws'
# Delete this once VPC support is merged upstream
require_relative 'aws_vpc_monkey_patch'

require_relative '../../runner'

class Instance
  attr_accessor :keyname
  attr_accessor :authn_error

  def authn_feature_failed?
    return true unless authn_error.nil?
  end

end

module Deltacloud
  module Drivers
    module Ec2
      class Ec2Driver < Deltacloud::BaseDriver

        feature :instances,
          :user_data,
          :authentication_key,
          :firewalls,
          :instance_count,
          :metrics,
          :attach_snapshot

        feature :images,
          :owner_id,
          :image_name,
          :image_description

        feature :buckets, :bucket_location

        DEFAULT_REGION = 'us-east-1'

        define_hardware_profile('t1.micro') do
          cpu                1
          memory             613
          storage            160
          architecture       ['i386','x86_64']
          root_type          :persistent
        end

        define_hardware_profile('m1.small') do
          cpu                1
          memory             1.7 * 1024
          storage            160
          architecture       ['i386', 'x86_64']
        end

        define_hardware_profile('m1.medium') do
          cpu                 2
          memory              3.75 * 1024
          storage             410
          architecture        ['i386', 'x86_64']
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
          architecture       ['i386', 'x86_64']
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
          stopping.to(:stopped)         .automatically

          stopped.to(:finish)         .on( :destroy)

        end

        # We do not allow users to set the endpoint through environment
        # variables. That that would work is an implementation detail.
        ENV.delete("EC2_URL")
        ENV.delete("S3_URL")
        ENV.delete("ELB_URL")

        def images(credentials, opts={})
          ec2 = new_client(credentials)
          img_arr = []
          opts ||= {}
          profiles = hardware_profiles(nil)
          if opts[:id]
            safely do
              begin
                img_arr = ec2.describe_images([opts[:id]]).collect do |image|
                  convert_image(image, profiles)
                end
              rescue => e
                raise e unless e.message =~ /Invalid id/ or e.message =~ /does not exist/
                img_arr = []
              end
            end
            return img_arr
          end
          owner_id = opts[:owner_id] || default_image_owner
          safely do
            img_arr = ec2.describe_images_by_owner([owner_id], default_image_type).collect do |image|
              convert_image(image, profiles)
            end
          end
          img_arr = filter_on( img_arr, :architecture, opts )
          img_arr.sort_by { |e| [e.owner_id, e.name] }
        end

        def realms(credentials, opts={})
          # We have two different kinds of realms:
          #  (1) Availability Zones
          #  (2) Subnets in VPC's (scoped to an AZ)
          # For the latter, the ID is AZ:SUBNET, and we can tell that we
          # are looking at such a realm by checking if the id contains a colon
          ec2 = new_client(credentials)
          realms = []
          safely do
            if opts[:id] and !opts[:id].empty?
              az, sn = opts[:id].split(":")
              begin
                if sn
                  subnet = ec2.describe_subnets(sn).first
                  realms << convert_realm(subnet) if subnet
                else
                  ec2.describe_availability_zones([az]).collect do |realm|
                    realms << convert_realm(realm) unless realm.empty?
                  end
                end
              rescue => e
                raise e unless e.message =~ /Invalid availability zone/
                realms = []
              end
            else
              realms = ec2.describe_availability_zones.collect do |realm|
                convert_realm(realm) unless realm.empty?
              end
              realms = realms +
                ec2.describe_subnets.map { |sn| convert_realm(sn) }
            end
          end
          realms
        end

        def create_image(credentials, opts={})
          ec2 = new_client(credentials)
          instance = instance(credentials, :id => opts[:id])
          safely do
            new_image_id = ec2.create_image(instance.id, opts[:name], opts[:description])
            image(credentials, :id => new_image_id)
          end
        end

        def destroy_image(credentials, image_id)
          ec2 = new_client(credentials)
          safely do
            unless ec2.deregister_image(image_id)
              raise "ERROR: Unable to deregister AMI"
            end
          end
        end

        def instance(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            begin
              ec2_inst = ec2.describe_instances([opts[:id]]).first
            rescue => e
              raise e unless e.message =~ /Invalid id/ or e.message =~ /NotFound/
              ec2_inst = nil
            end
            return if ec2_inst.nil?
            instance = convert_instance(ec2_inst)
            return nil unless instance
            if ec2_inst[:aws_platform] == 'windows'
              console_output = ec2.get_console_output(instance.id)
              windows_password = console_output[:aws_output][%r{<Password>(.+)</Password>}m] && $1
              if windows_password
                instance.username = 'Administrator'
                instance.password = windows_password
              end
            end
            instance
          end
        end

        def instances(credentials, opts={})
          ec2 = new_client(credentials)
          inst_arr = []
          safely do
            inst_arr = ec2.describe_instances.collect do |instance|
              convert_instance(instance) if instance
            end.flatten
          end
          inst_arr = filter_on( inst_arr, :id, opts )
          filter_on( inst_arr, :state, opts )
        end

        def create_instance(credentials, image_id, opts={})
          ec2 = new_client(credentials)
          instance_options = {}
          if opts[:user_data]
            instance_options[:user_data] = Base64::decode64(opts[:user_data])
          end
          if opts[:metrics] and !opts[:metrics].empty?
            instance_options[:monitoring_enabled] = true
          end
          instance_options[:availability_zone] = opts[:realm_id] if opts[:realm_id]
          instance_options[:subnet_id] = opts[:subnet_id] if opts[:subnet_id] #FIXME should we fail if no :network_id ? don't need it but need consistency in API...
          instance_options[:key_name] = opts[:keyname] if opts[:keyname]
          instance_options[:instance_type] = opts[:hwp_id] if opts[:hwp_id] && opts[:hwp_id].length > 0
          firewalls = opts.inject([]){|res, (k,v)| res << v if k =~ /firewalls\d+$/; res}
          instance_options[:group_ids] = firewalls unless firewalls.empty?
          if opts[:instance_count] and opts[:instance_count].length != 0
            instance_options[:min_count] = opts[:instance_count]
            instance_options[:max_count] = opts[:instance_count]
          end
          if opts[:snapshot_id] and opts[:device_name]
            instance_options[:block_device_mappings] = [{
              :snapshot_id => opts[:snapshot_id],
              :device_name => opts[:device_name]
            }]
          end
          safely do
            new_instances = ec2.launch_instances(image_id, instance_options).collect do |i|
              convert_instance(i)
            end
            if new_instances.size == 1
              new_instances.first
            else
              new_instances
            end
          end
        end

        def run_on_instance(credentials, opts={})
          target = instance(credentials, :id => opts[:id])
          param = {}
          param[:credentials] = {
            :username => (opts[:username]) ? opts[:username] : 'root', # Default for EC2 Linux instances
          }
          param[:port] = opts[:port] || '22'
          param[:ip] = opts[:ip] || target.public_addresses.first.address
          param[:private_key] = (opts[:private_key].length > 1) ? opts[:private_key] : nil
          safely do
            Deltacloud::Runner.execute(opts[:cmd], param)
          end
        end

        def reboot_instance(credentials, instance_id)
          ec2 = new_client(credentials)
          if ec2.reboot_instances([instance_id])
            instance(credentials, :id => instance_id)
          else
            raise Deltacloud::BackendError.new(500, "Instance", "Instance reboot failed", "")
          end
        end

        def stop_instance(credentials, instance_id)
          ec2 = new_client(credentials)
          if ec2.stop_instances([instance_id])
            instance(credentials, :id => instance_id)
          else
            raise Deltacloud::BackendError.new(500, "Instance", "Instance stop failed", "")
          end
        end


        def destroy_instance(credentials, instance_id)
          ec2 = new_client(credentials)
          if ec2.terminate_instances([instance_id])
            instance(credentials, :id => instance_id)
          else
            raise Deltacloud::BackendError.new(500, "Instance", "Instance cannot be terminated", "")
          end
        end

        def metrics(credentials, opts={})
          cw = new_client(credentials, :mon)
          metrics_arr = []
          cw.list_metrics( :namespace => 'AWS/EC2' ).each do |metric|
            if metrics_arr.any? { |m| m.id == metric[:value] }
              i = metrics_arr.index { |m| m.id == metric[:value] }
              metrics_arr[i] = metrics_arr[i].add_property(metric[:measure_name])
            else
              metrics_arr << convert_metric(metric)
            end
          end
          metrics_arr.reject! { |m| m.unknown? }
          filter_on(metrics_arr, :id, opts)
        end

        def metric(credentials, opts={})
          cw = new_client(credentials, :mon)
          m = metrics(credentials, :id => opts[:id])
          return [] if m.empty?
          m = m.first
          # Get statistics from last 1 hour
          start_time = (Time.now - 3600).utc.iso8601.to_s
          end_time = Time.now.utc.iso8601.to_s
          m.properties.each do |p|
            p.values = cw.get_metric_statistics(p.name,  ['Minimum', 'Maximum', 'Average'],
                        start_time, end_time, metric_unit_for(p.name), { m.entity => opts[:id]})
          end
          m
        end

        def keys(credentials, opts={})
          ec2 = new_client(credentials)
          opts ||= {}
          safely do
            begin
              ec2.describe_key_pairs(opts[:id] ? [opts[:id]] : nil).collect do |key|
                convert_key(key)
              end
            rescue => e
              raise e unless e.message =~ /does not exist/
              []
            end
          end
        end

        def create_key(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            if (opts[:public_key] && opts[:public_key].length >0)
              convert_key(ec2.import_key_pair(opts[:key_name], opts[:public_key]))
            else
              convert_key(ec2.create_key_pair(opts[:key_name]))
            end
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

        def load_balancer(credentials, opts={})
          load_balancers(credentials, {
            :names => [opts[:id]]
          }).first
        end

        def load_balancers(credentials, opts=nil)
          ec2 = new_client( credentials, :elb )
          result = []
          safely do
            loadbalancers = ec2.describe_load_balancers(opts || {})
            loadbalancers.each do |loadbalancer|
              result << convert_load_balancer(credentials, loadbalancer)
            end
          end
          return result
        end

        def create_load_balancer(credentials, opts={})
          ec2 = new_client( credentials, :elb )
          safely do
            ec2.create_load_balancer(opts['name'], [opts['realm_id']],
              [{:load_balancer_port => opts['listener_balancer_port'],
                :instance_port => opts['listener_instance_port'],
                :protocol => opts['listener_protocol']}]
            )
            return load_balancer(credentials, :id => opts['name'])
          end
        end

        def destroy_load_balancer(credentials, id)
          ec2 = new_client( credentials, :elb )
          return 'InvalidLoadBalancer' if load_balancer(credentials, :id => id).nil?
          safely do
            ec2.delete_load_balancer(id)
          end
        end

        def lb_register_instance(credentials, opts={})
          ec2 = new_client( credentials, :elb)
          safely do
            ec2.register_instances_with_load_balancer(opts['id'], [opts['instance_id']])
            load_balancer(credentials, :id => opts[:id])
          end
        end

        def lb_unregister_instance(credentials, opts={})
          ec2 = new_client( credentials, :elb)
          safely do
            ec2.deregister_instances_from_load_balancer(opts['id'], [opts['instance_id']])
            load_balancer(credentials, :id => opts['id'])
          end
        end

        def buckets(credentials, opts={})
          buckets = []
          safely do
            s3_client = new_client(credentials, :s3)
            unless (opts[:id].nil?)
              bucket, s3_client = get_bucket_with_endpoint(s3_client, credentials, opts[:id])
              buckets << convert_bucket(bucket)
            else
              bucket_list = s3_client.buckets
              bucket_list.each do |current|
                buckets << Bucket.new({:name => current.name, :id => current.name})
              end
            end
          end
          filter_on(buckets, :id, opts)
        end

        def create_bucket(credentials, name, opts={})
          bucket = nil
          safely do
            s3_client = new_client(credentials, :s3)
            bucket_location = opts['location']
            if (bucket_location && bucket_location.size >0 &&
                                               (not bucket_location.eql?(DEFAULT_REGION)) )
              bucket = Aws::S3::Bucket.create(s3_client, name, true, nil, :location => bucket_location)
            else
              bucket = Aws::S3::Bucket.create(s3_client, name, true)
            end
          end
          convert_bucket(bucket)
        end

        def delete_bucket(credentials, name, opts={})
          s3_client = new_client(credentials, :s3)
          s3_bucket, s3_client = get_bucket_with_endpoint(s3_client, credentials, name)
          safely do
            s3_client.interface.delete_bucket(name)
          end
        end

        def blobs(credentials, opts = {})
          s3_client = new_client(credentials, :s3)
          blobs = []
          safely do
            s3_bucket, s3_client = get_bucket_with_endpoint(s3_client, credentials, opts['bucket'])
            if(opts[:id])
              blobs << convert_object(s3_bucket.key(opts[:id], true))
            else
              s3_bucket.keys({}, true).each do |s3_object|
                blobs << convert_object(s3_object)
              end
            end
          end
          blobs = filter_on(blobs, :id, opts)
          blobs
        end

        #--
        # Create Blob - NON Streaming way (i.e. was called with POST html multipart form data)
        #--
        #also called for segmented blobs - as final call with blob manifest
        def create_blob(credentials, bucket_id, blob_id, data = nil, opts = {})
          s3_client = new_client(credentials, :s3)
          #data is a construct with the temporary file created by server @.tempfile
          #also file[:type] will give us the content-type
          if(opts[:segment_manifest])
            safely do
              s3_client.interface.complete_multipart(bucket_id, blob_id, opts[:segmented_blob_id], opts[:segment_manifest])
            end
          else
            # File stream needs to be reopened in binary mode
            file = File::open(data[:tempfile].path, 'rb')
            #insert ec2-specific header for user metadata ... x-amz-meta-KEY = VALUE
            BlobHelper::rename_metadata_headers(opts, 'x-amz-meta-')
            opts["Content-Type"] = data[:type]
            safely do
              s3_client.interface.put(bucket_id,
                                          blob_id,
                                          file,
                                          opts)
            end
          end
          #create a new Blob object and return that
          Blob.new( { :id => blob_id,
                      :bucket => bucket_id,
                      :content_length => ((data && data[:tempfile]) ? data[:tempfile].length : nil),
                      :content_type => ((data && data[:type]) ? data[:type] : nil),
                      :last_modified => '',
                      :user_metadata => opts.select{|k,v| k.match(/^x-amz-meta-/i)}
                    }
                  )
        end

        def init_segmented_blob(credentials, opts={})
          s3_client = new_client(credentials, :s3)
          safely do
            s3_client.interface.initiate_multipart(opts[:bucket],opts[:id])
          end

        end

        def blob_segment_id(request, response)
          response["etag"].gsub("\"", "")
        end

        #--
        # Delete Blob
        #--
        def delete_blob(credentials, bucket_id, blob_id, opts={})
          s3_client = new_client(credentials, :s3)
          safely do
            s3_client.interface.delete(bucket_id, blob_id)
          end
        end

        def blob_metadata(credentials, opts={})
          s3_client = new_client(credentials, :s3)
          blob_meta = {}
          safely do
            the_bucket, s3_client = get_bucket_with_endpoint(s3_client, credentials, opts['bucket'])
            the_blob = the_bucket.key(opts[:id], true)
            blob_meta = the_blob.meta_headers
          end
        end

        def update_blob_metadata(credentials, opts={})
          s3_client = new_client(credentials, :s3)
          meta_hash = BlobHelper::rename_metadata_headers(opts['meta_hash'], '')
          safely do
            the_bucket, s3_client = get_bucket_with_endpoint(s3_client, credentials, opts['bucket'])
            the_blob = the_bucket.key(opts[:id])
            the_blob.save_meta(meta_hash)
          end
        end

        def blob_data(credentials, bucket_id, blob_id, opts={})
          s3_client = new_client(credentials, :s3)
          s3_client = get_bucket_with_endpoint(s3_client, credentials, bucket_id)[1]
          safely do
            s3_client.interface.get(bucket_id, blob_id) do |chunk|
              yield chunk
            end
          end
        end

        #params: {:user,:password,:bucket,:blob,:content_type,:content_length,:metadata}
        def blob_stream_connection(params)
          #canonicalise metadata:
          #http://docs.amazonwebservices.com/AmazonS3/latest/dev/index.html?RESTAuthentication.html
          metadata = params[:metadata] || {}
          signature_meta_string = ""
          BlobHelper::rename_metadata_headers(metadata, 'x-amz-meta-')
          keys_array = metadata.keys.sort!
          keys_array.each {|k| signature_meta_string << "#{k}:#{metadata[k]}\n"}
          provider = "https://#{endpoint_for_service(:s3)}"
          uri = URI.parse(provider)
          http = Net::HTTP.new("#{params[:bucket]}.#{uri.host}", uri.port )
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          timestamp = Time.now.httpdate
          string_to_sign =
            "PUT\n\n#{params[:content_type]}\n#{timestamp}\n#{signature_meta_string}/#{params[:bucket]}/#{params[:blob]}"
          if BlobHelper.segmented_blob_op_type(params[:context]) == "segment"
            partNumber = BlobHelper.segment_order(params[:context])
            uploadId = BlobHelper.segmented_blob_id(params[:context])
            segment_string = "?partNumber=#{partNumber}&uploadId=#{uploadId}"
            string_to_sign << segment_string
            request = Net::HTTP::Put.new("/#{params[:blob]}#{segment_string}")
          else
            request = Net::HTTP::Put.new("/#{params[:blob]}")
          end
          auth_string = Aws::Utils::sign(params[:password], string_to_sign)
          request['Host'] = "#{params[:bucket]}.#{uri.host}"
          request['Date'] = timestamp
          request['Content-Type'] = params[:content_type]
          request['Content-Length'] = params[:content_length]
          request['Authorization'] = "AWS #{params[:user]}:#{auth_string}"
          request['Expect'] = "100-continue"
          metadata.each{|k,v| request[k] = v}
          return http, request
        end

        def storage_volumes(credentials, opts={})
          ec2 = new_client( credentials )
          volume_list = (opts and opts[:id]) ? [opts[:id]] : []
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
            storage_volume(credentials, :id => opts[:id])
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
          snapshot_list = opts[:id] ? [opts[:id]] : []
          safely do
            begin
            ec2.describe_snapshots(snapshot_list).collect do |snapshot|
              convert_snapshot(snapshot)
            end
            rescue => e
              if e.message =~ /NotFound/
                []
              else
                raise e
              end
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
            unless ec2.delete_snapshot(opts[:id])
              raise Deltacloud::BackendError.new(500, "StorageSnapshot", "Cannot destroy this snapshot")
            end
          end
        end

        def addresses(credentials, opts={})
          ec2 = new_client(credentials)
          address_id = (opts and opts[:id]) ? [opts[:id]] : []
          safely do
            begin
              ec2.describe_addresses(address_id).collect do |address|
                Address.new(:id => address[:public_ip], :instance_id => address[:instance_id])
              end
            rescue Exception => e
              return [] if e.message =~ /InvalidAddress\.NotFound:/
              raise e
            end
          end
        end

        def create_address(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            Address.new(:id => ec2.allocate_address)
          end
        end

        def destroy_address(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            ec2.release_address(opts[:id])
          end
        end

        def associate_address(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            if ec2.associate_address(opts[:instance_id], opts[:id])
              Address.new(:id => opts[:id], :instance_id => opts[:instance_id])
            else
              raise "ERROR: Cannot associate IP address to an Instance"
            end
          end
        end

        def disassociate_address(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            if ec2.disassociate_address(opts[:id])
              Address.new(:id => opts[:id])
            else
              raise "ERROR: Cannot disassociate an IP address from the Instance"
            end
          end
        end

#--
#FIREWALLS - ec2 security groups
#--
        def firewalls(credentials, opts={})
          ec2 = new_client(credentials)
          the_firewalls = []
          groups = []
          safely do
            if opts[:id]
              groups = ec2.describe_security_groups([opts[:id]])
            else
              groups = ec2.describe_security_groups()
            end
          end
          groups.each do |security_group|
            the_firewalls << convert_security_group(security_group)
          end
          the_firewalls
        end

#--
#Create firewall
#--
        def create_firewall(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            ec2.create_security_group(opts["name"], opts["description"])
          end
          Firewall.new( { :id=>opts["name"], :name=>opts["name"],
                          :description => opts["description"], :owner_id => "", :rules => [] } )
        end

#--
#Delete firewall
#--
        def delete_firewall(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            ec2.delete_security_group(opts["id"])
          end
        end
#--
#Create firewall rule
#--
        def create_firewall_rule(credentials, opts={})
          ec2 = new_client(credentials)
          groups = []
          opts['groups'].each do |k,v|
            groups << {"group_name" => k, "owner" =>v}
          end
          safely do
            ec2.manage_security_group_ingress(opts['id'], opts['port_from'], opts['port_to'], opts['protocol'],
              "authorize", opts['addresses'], groups)
          end
        end
#--
#Delete firewall rule
#--
        def delete_firewall_rule(credentials, opts={})
          ec2 = new_client(credentials)
          firewall = opts[:firewall]
          protocol, from_port, to_port, addresses, groups = firewall_rule_params(opts[:rule_id])
          safely do
            ec2.manage_security_group_ingress(firewall, from_port, to_port, protocol, "revoke", addresses, groups)
          end
        end

        #Deltacloud Networks == Amazon VPC
        def networks(credentials, opts={})
          ec2 = new_client(credentials)
          networks = []
          safely do
            subnets = subnets(credentials) #get all subnets once
            (opts[:id] ? ec2.describe_vpcs(opts[:id]) : ec2.describe_subnets).each do |vpc|
              vpc_subnets = subnets.inject([]){|res,cur| res<<cur if cur.network==vpc[:vpc_id]  ;res} #collect subnets for this.network
              networks << convert_vpc(vpc, vpc_subnets)
            end
          end
          networks = filter_on(networks, :id, opts)
        end

        def create_network(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            network = ec2.create_vpc(opts[:address_block]).first
            convert_vpc(network)
          end
        end

        def destroy_network(credentials, network_id)
          ec2 = new_client(credentials)
          safely do
            ec2.delete_vpc(network_id)
          end
        end

        def subnets(credentials, opts={})
          ec2 = new_client(credentials)
          subnets = []
          safely do
            (opts[:id] ? ec2.describe_subnets(opts[:id]) : ec2.describe_subnets).each do |sn|
              subnets << convert_subnet(sn)
            end
          end
          subnets = filter_on(subnets, :id, opts)
        end

        def create_subnet(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            subnet = ec2.create_subnet(opts[:network_id], opts[:address_block]).first
            convert_subnet(subnet)
          end
        end

        def destroy_subnet(credentials, subnet_id)
          ec2 = new_client(credentials)
          safely do
            ec2.delete_subnet(subnet_id)
          end
        end

        def network_interfaces(credentials, opts={})
          ec2 = new_client(credentials)
          nics = []
          safely do
            (opts[:id] ? ec2.describe_network_interfaces(opts[:id]) : ec2.describe_network_interfaces).each do |nic|
              nics << convert_nic(nic)
            end
          end
          filter_on(nics, :id, opts)
        end

        def create_network_interface(credentials, opts={})
          ec2 = new_client(credentials)
          safely do
            #create a nic:
            nic = ec2.create_network_interface(opts[:network])
            #retrieve the instance to determine appropriate device_index?
            #attach it:
            ec2.attach_network_interface(nic[:network_interface_id], opts[:instance], 0)
            convert_nic(nic)
          end
        end

        def destroy_network_interface(credentials, nic_id)
          client = new_client(credentials)
          safely do
            client.delete_network_interface(nic_id)
          end
        end

        def providers(credentials, opts={})
          ec2 = new_client(credentials)
          @providers ||= ec2.describe_regions.map{|r| Provider.new( {:id=>r, :name=>r,
           :url=>"#{ENV['API_HOST']}:#{ENV['API_PORT']}#{Deltacloud.default_frontend.root_url}\;provider=#{r}" }) }
        end

        def configured_providers
          Deltacloud::Drivers::driver_config[:ec2][:entrypoints]["ec2"].keys
        end

        def valid_credentials?(credentials)
          begin
            realms(credentials) && true
          rescue => e
            if e.class.name =~ /AuthFailure/
              false
            else
              safely { raise e }
            end
          end
        end

        private
        def new_client(credentials, type = :ec2, endpoint = nil)
          klass = case type
                    when :elb then Aws::Elb
                    when :ec2 then Aws::Ec2
                    when :s3 then Aws::S3
                    when :mon then Aws::Mon
                  end
          klass.new(credentials.user, credentials.password, {
            :server => endpoint || endpoint_for_service(type),
            :connection_mode => :per_thread,
            :logger => ENV['RACK_ENV'] == 'test' ? Logger.new(StringIO.new) : Logger.new(STDOUT)
          })
        end

        def default_image_owner
          "amazon"
        end

        def default_image_type
          "machine"
        end

        def endpoint_for_service(service)
          endpoint = (api_provider || DEFAULT_REGION)
          # return the endpoint if it does not map to a default endpoint, allowing
          # the endpoint to be a full hostname instead of a region.
          Deltacloud::Drivers::driver_config[:ec2][:entrypoints][service.to_s][endpoint] || endpoint
        end

        def get_bucket_with_endpoint(s3_client, credentials, s3_bucket_name)
            s3_bucket = s3_client.bucket(s3_bucket_name)
            endpoint_for_bucket = Deltacloud::Drivers::driver_config[:ec2][:entrypoints]["s3"]["#{s3_bucket.location}"] || "s3.amazonaws.com"
            if (s3_client.interface.params[:server] != endpoint_for_bucket)
              s3_client = new_client(credentials, :s3, endpoint_for_bucket)
              s3_bucket = s3_client.bucket(s3_bucket_name)
            end
            [s3_bucket, s3_client]
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
            :size => blob_list.length,
            :blob_list => blob_list
          )
        end

        def convert_object(s3_object)
          Blob.new(
            :id => s3_object.name,
            :bucket => s3_object.bucket.name.to_s,
            :content_length => s3_object.headers['content-length'],
            :content_type => s3_object.headers['content-type'],
            :last_modified => s3_object.last_modified,
            :user_metadata => s3_object.meta_headers
          )
        end

        def convert_realm(realm)
          # We also allow subnets as realms
          if realm[:subnet_id]
            realm[:zone_name] =
              "#{realm[:availability_zone]}:#{realm[:subnet_id]}"
            realm[:zone_state] = realm[:state]
          end
          Realm.new(
            :id => realm[:zone_name],
            :name => realm[:zone_name],
            :state => realm[:zone_state],
            :limit => realm[:zone_state].eql?('available') ? :unlimited : 0
          )
        end

        def convert_image(image, profiles)
          # There is not support for 'name' for now
          Image.new(
            :id => image[:aws_id],
            :name => image[:aws_name] || image[:aws_id],
            :description => image[:aws_description] || image[:aws_location],
            :owner_id => image[:aws_owner],
            :architecture => image[:aws_architecture],
            :hardware_profiles => image_profiles(image, profiles),
            :state => image[:aws_state],
            :root_type => convert_root_type(image[:aws_root_device_type])
          )
        end

        def convert_root_type(type)
          type == 'ebs' ? 'persistent' : 'transient'
        end

        def convert_instance(instance)
          can_create_image = 'ebs'.eql?(instance[:root_device_type]) and 'RUNNING'.eql?(convert_state(instance[:aws_state]))
          inst_profile_opts={}
          if instance[:aws_instance_type] == "t1.micro"
            inst_profile_opts[:hwp_architecture]=instance[:architecture]
          end
          realm_id = instance[:aws_availability_zone]
          unless instance[:subnet_id].empty?
            realm_id = "#{realm_id}:#{instance[:subnet_id]}"
          end
          inst_params = {
            :id => instance[:aws_instance_id],
            :name => instance[:aws_image_id],
            :state => convert_state(instance[:aws_state]),
            :image_id => instance[:aws_image_id],
            :owner_id => instance[:aws_owner],
            :actions => instance_actions_for(convert_state(instance[:aws_state])),
            :keyname => instance[:ssh_key_name],
            :launch_time => instance[:aws_launch_time],
            :instance_profile => InstanceProfile.new(instance[:aws_instance_type], inst_profile_opts),
            :realm_id => realm_id,
            :public_addresses => [InstanceAddress.new(instance[:dns_name], :type => :hostname)],
            :private_addresses => [InstanceAddress.new(instance[:private_dns_name], :type => :hostname)],
            :firewalls => instance[:aws_groups],
            :storage_volumes => instance[:block_device_mappings].map{|vol| {vol.values.first=>vol.keys.first } },
            :create_image => can_create_image }
#          if instance[:vpc_id]
#            inst_params.merge!(:network_bindings => [{:network=>instance[:vpc_id], :subnet=>instance[:subnet_id], :ip_address=> instance[:aws_private_ip_address]}])
#          end
          Instance.new(inst_params)
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

        def image_profiles(image, profiles)
          profiles = filter_hardware_profiles(profiles, :architecture => image[:aws_architecture])
          if image[:aws_root_device_type] != 'ebs'
            profiles.reject { |p| p.name == 't1.micro' }
          else
            profiles
          end
        end

        def convert_load_balancer(credentials, loadbalancer)
          realms = []
          loadbalancer[:availability_zones].each do |zone|
            realms << realm(credentials, :id => zone)
          end
          balancer = LoadBalancer.new({
            :id => loadbalancer[:name],
            :created_at => loadbalancer[:created_time],
            :public_addresses => [loadbalancer[:dns_name]],
            :realms => realms
          })
          balancer.listeners = []
          balancer.instances = []
          loadbalancer[:listeners].each do |listener|
            balancer.add_listener(listener)
          end
          loadbalancer[:instances].each do |instance|
            balancer.instances << instance(credentials, :id => instance[:instance_id])
          end
          balancer
        end

        #generate uid from firewall rule parameters (amazon doesn't do this for us
        def firewall_rule_id(user_id, protocol, from_port, to_port, sources)
          sources_string = ""
          sources.each do |source|
          if source[:type].to_s == "group"
            sources_string << "@#{source[:type]},#{source[:owner]},#{source[:name]},"
          else
            sources_string << "@#{source[:type]},#{source[:family]},#{source[:address]},#{source[:prefix]},"
          end
        end
         #sources_string is @group,297467797945,test@address,ipv4,10.1.1.1,24 etc
         "#{user_id}~#{protocol}~#{from_port}~#{to_port}~#{sources_string.chomp!(",")}"
#sources_string.slice(0,sources_string.length-1)}"
        end

        #extract params from uid
        def firewall_rule_params(id)
          #user_id~protocol~from_port~to_port~sources_string
          params = id.split("~")
          protocol = params[1]
          from_port = params[2]
          to_port = params[3]
          sources = params[4].split("@")
          sources.shift #first match is ""
          addresses = []
          groups = []
          #@group,297467797945,test@address,ipv4,10.1.1.1,24@address,ipv4,192.168.1.1,24
          sources.each do |source|
            current = source.split(",")
            type = current[0]
            case type
              when 'group'
                #group,297467797945,test
                owner = current[1]
                name = current[2]
                groups << {'group_name' => name, 'owner' => owner}
              when 'address'
                #address,ipv4,10.1.1.1,24
                address = current[2]
                address<<"/#{current[3]}"
                addresses << address
            end
          end
          return protocol, from_port, to_port, addresses, groups
        end

        #Convert ec2 security group to server/lib/deltacloud/models/firewall
        def convert_security_group(security_group)
          rules = []
          security_group[:aws_perms].each do |perm|
            sources = []
            perm[:groups].each do |group|
              sources << {:type => "group", :name => group[:group_name], :owner => group[:owner]}
            end
            perm[:ip_ranges].each do |ip|
              sources << {:type => "address", :family=>"ipv4",
                          :address=>ip[:cidr_ip].split("/").first,
                          :prefix=>ip[:cidr_ip].split("/").last}
            end
            rule_id = firewall_rule_id(security_group[:aws_owner], perm[:protocol],
                                       perm[:from_port] , perm[:to_port], sources)
            rules << FirewallRule.new({:id => rule_id,
                                        :allow_protocol => perm[:protocol],
                                        :port_from => perm[:from_port],
                                        :port_to => perm[:to_port],
                                        :direction => 'ingress',
                                        :sources => sources})
          end
          Firewall.new(  {  :id => security_group[:aws_group_name],
                            :name => security_group[:aws_group_name],
                            :description => security_group[:aws_description],
                            :owner_id => security_group[:aws_owner],
                            :rules => rules
                      }  )
        end

        def metric_unit_for(name)
          case name
            when /Bytes/ then 'Bytes'
            when /Ops/ then 'Count'
            when /Count/ then 'Count'
            when /Utilization/ then 'Percent'
            when /Network/ then 'Bytes'
            else 'None'
          end
        end

        def convert_metric(metric)
          Metric.new(
            :id => metric[:value],
            :entity => metric[:name] || :unknown
          ).add_property(metric[:measure_name])
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

        def convert_vpc(vpc, subnets=[])
          addr_blocks = subnets.inject([]){|res,cur| res << cur.address_block  ; res}
          Network.new({ :id => vpc[:vpc_id],
                        :name => vpc[:vpc_id],
                        :state=> (vpc[:state] == "available" ? "UP" : "DOWN"),
                        :subnets => subnets.inject([]){|res,cur| res << cur.id  ;res},
                        :address_blocks=> (addr_blocks.empty? ? [vpc[:cidr_block]] : addr_blocks)  })
        end

        def convert_subnet(subnet)
          Subnet.new({  :id => subnet[:subnet_id],
                        :name => subnet[:subnet_id],
                        :network =>subnet[:vpc_id],
                        :address_block => subnet[:cidr_block],
                        :state => (subnet[:state] == "available" ? "UP" : "DOWN" )})
        end

        def convert_nic(nic, instance_id=nil)
          instance = instance_id || (nic[:attachment] ? nic[:attachment][:instance_id] : nil)
          NetworkInterface.new({  :id => nic[:network_interface_id],
                                  :name => nic[:network_interface_id],
                                  :instance => instance,
                                  :ip_address => nic[:private_ip_address]
                                })
        end

        exceptions do

          on /root device is not supported for the instance/ do
            status 400
          end

          on /(AuthFailure|InvalidAccessKeyId)/ do
            status 401
          end

          on /(NotFound|InvalidInstanceID|InvalidAMIID|InvalidLoadBalancer|LoadBalancerNotFound)/ do
            status 404
          end

          on /Bad Request.*elasticloadbalancing/ do
            status 404
          end

          on /Invalid availability zone/ do
            status 404
          end

          on /Error/ do
            status 502
          end

          on /Deltacloud::Runner::(\w+)/ do
            status 500
          end
        end

      end
    end
  end
end
