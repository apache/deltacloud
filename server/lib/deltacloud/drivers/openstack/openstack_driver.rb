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
require 'openstack/compute'
require 'tempfile'
module Deltacloud
  module Drivers
    module Openstack
      class OpenstackDriver < Deltacloud::BaseDriver

        feature :instances, :user_name
        feature :instances, :authentication_password
        feature :instances, :user_files
        feature :images, :user_name

        def supported_collections
          DEFAULT_COLLECTIONS - [ :storage_snapshots, :storage_volumes  ] #+ [ :buckets ]
        end

        define_instance_states do
          start.to( :pending )          .on( :create )
          pending.to( :running )        .automatically
          running.to( :running )        .on( :reboot )
          running.to( :stopping )       .on( :stop )
          stopping.to( :stopped )       .automatically
          stopped.to( :finish )         .automatically
        end

        def hardware_profiles(credentials, opts = {})
          os = new_client(credentials)
          results = []
          safely do
            if opts[:id]
              flavor = os.flavor(opts[:id])
              results << convert_from_flavor(flavor)
            else
              results = os.flavors.collect do |f|
                convert_from_flavor(f)
              end
            end
            filter_hardware_profiles(results, opts)
          end
        end

        def images(credentials, opts={})
          os = new_client(credentials)
          results = []
          profiles = hardware_profiles(credentials)
          safely do
            if(opts[:id])
              img = os.get_image(opts[:id])
              results << convert_from_image(img, os.authuser)
            else
              results = os.list_images.collect do |img|
                convert_from_image(img, os.authuser)
              end
            end
          end
          results.each do |img|
            img.hardware_profiles = profiles
          end
          filter_on(results, :owner_id, opts)
        end

        def create_image(credentials, opts)
          os = new_client(credentials)
          safely do
            server = os.get_server(opts[:id])
            image_name = opts[:name] || "#{server.name}_#{Time.now}"
            img = server.create_image(:name=>image_name)
            convert_from_image(img, os.authuser)
          end
        end

        def destroy_image(credentials, image_id)
          os = new_client(credentials)
          safely do
            image = os.get_image(image_id)
            unless image.delete!
              raise "ERROR: Cannot delete image with ID:#{image_id}"
            end
          end
        end

        def realms(credentials, opts={})
          os = new_client(credentials)
          limits = ""
          safely do
            lim = os.limits
              limits << "ABSOLUTE >> Max. Instances: #{lim[:absolute][:maxTotalInstances]} Max. RAM: #{lim[:absolute][:maxTotalRAMSize]}   ||   "
              lim[:rate].each do |rate|
                if rate[:regex] =~ /servers/
                  limits << "SERVERS >> Total: #{rate[:limit].first[:value]}  Remaining: #{rate[:limit].first[:remaining]} Time Unit: per #{rate[:limit].first[:unit]}"
                end
              end
          end
          [ Realm.new( { :id=>'default',
                        :name=>'default',
                        :limit => limits,
                        :state=>'AVAILABLE' })]
        end

        def instances(credentials, opts={})
          os = new_client(credentials)
          insts = []
          safely do
            if opts[:id]
              server = os.get_server(opts[:id].to_i)
              insts << convert_from_server(server, os.authuser)
            else
              insts = os.list_servers_detail.collect do |server|
                convert_from_server(server, os.authuser)
              end
            end
          end
          insts = filter_on( insts, :state, opts )
          insts
        end

        def create_instance(credentials, image_id, opts)
          os = new_client( credentials )
          result = nil
#opts[:personality]: path1='server_path1'. content1='contents1', path2='server_path2', content2='contents2' etc
          params = extract_personality(opts)
#          ref_prefix = get_prefix(os)
          params[:name] = (opts[:name] && opts[:name].length>0)? opts[:name] : Time.now.to_s
          params[:imageRef] = image_id
          params[:flavorRef] =  (opts[:hwp_id] && opts[:hwp_id].length>0) ?
                          opts[:hwp_id] : hardware_profiles(credentials).first.name
          if opts[:password] && opts[:password].length > 0
            params[:adminPass]=opts[:password]
          end
          safely do
            server = os.create_server(params)
            result = convert_from_server(server, os.authuser)
          end
          result
        end

        def reboot_instance(credentials, instance_id)
          os = new_client(credentials)
          safely do
            server = os.get_server(instance_id.to_i)
            server.reboot! # sends a hard reboot (power cycle) - could instead server.reboot("SOFT")
            convert_from_server(server, os.authuser)
          end
        end

        def destroy_instance(credentials, instance_id)
          os = new_client(credentials)
          safely do
            server = os.get_server(instance_id.to_i)
            server.delete!
            convert_from_server(server, os.authuser)
          end
        end

        alias_method :stop_instance, :destroy_instance

        def valid_credentials?(credentials)
          begin
            new_client(credentials)
          rescue
            return false
          end
          true
        end

        def buckets(credentials, opts={})

        end

        def create_bucket(credentials, name, opts={})

        end

        def delete_bucket(credentials, name, opts={})

        end

        def blobs(credentials, opts={})

        end

        def blob_data(credentials, bucket, blob, opts={})

        end

        def create_blob(credentials, bucket, blob, data, opts={})

        end

        def delete_blob(credentials, bucket, blob, opts={})

        end

        def blob_metadata(credentials, opts={})

        end

        def update_blob_metadata(credentials, opts={})

        end

        def blob_stream_connection(params)

        end

private

        #for v2 authentication credentials.name == "username+tenant_name"
        def new_client(credentials, buckets=false)
          tokens = credentials.user.split("+")
          if (tokens.size != 2 && api_v2)
            raise ValidationFailure.new(Exception.new("Error: expected \"username+tenantname\" as username, you provided: #{credentials.user}"))
          else
            user_name, tenant_name = tokens.first, tokens.last
          end
          safely do
              OpenStack::Compute::Connection.new(:username => user_name, :api_key => credentials.password, :authtenant => tenant_name, :auth_url => api_provider)
          end
        end

        def cloudfiles_client(credentials)
          safely do
            CloudFiles::Connection.new(:username => credentials.user, :api_key => credentials.password)
          end
        end

#NOTE: for the convert_from_foo methods below... openstack-compute
#gives Hash for 'flavors' but OpenStack::Compute::Flavor for 'flavor'
#hence the use of 'send' to deal with both cases and save duplication

        def convert_from_flavor(flavor)
          op = (flavor.class == Hash)? :fetch : :send
          HardwareProfile.new(flavor.send(op, :id).to_s) do
            architecture 'x86_64'
            memory flavor.send(op, :ram).to_i
            storage flavor.send(op, :disk).to_i
            cpu flavor.send(op, :vcpus).to_i
          end
        end

        def convert_from_image(image, owner)
          op = (image.class == Hash)? :fetch : :send
          Image.new({
                    :id => image.send(op, :id),
                    :name => image.send(op, :name),
                    :description => image.send(op, :name),
                    :owner_id => owner,
                    :state => image.send(op, :status),
                    :architecture => 'x86_64'
                    })
        end

        def convert_from_server(server, owner)
          op = (server.class == Hash)? :fetch : :send
          image = server.send(op, :image)
          flavor = server.send(op, :flavor)
          begin
            password = server.send(op, :adminPass) || ""
            rescue IndexError
              password = ""
          end
          inst = Instance.new(
            :id => server.send(op, :id).to_s,
            :realm_id => 'default',
            :owner_id => owner,
            :description => server.send(op, :name),
            :name => server.send(op, :name),
            :state => (server.send(op, :status) == 'ACTIVE') ? 'RUNNING' : 'PENDING',
            :architecture => 'x86_64',
            :image_id => image[:id] || image["id"],
            :instance_profile => InstanceProfile::new(flavor[:id] || flavor["id"]),
            :public_addresses => convert_server_addresses(server, :public),
            :private_addresses => convert_server_addresses(server, :private),
            :username => 'root',
            :password => password
          )
          inst.actions = instance_actions_for(inst.state)
          inst.create_image = 'RUNNING'.eql?(inst.state)
          inst
        end

        def convert_server_addresses(server, type)
          op, address_label = (server.class == Hash)? [:fetch, :addr] : [:send, :address]
          addresses = (server.send(op, :addresses)[type] || []).collect do |addr|
            type = (addr.send(op, :version) == 4)? :ipv4 : :ipv6
            InstanceAddress.new(addr.send(op, address_label), {:type=>type} )
          end
        end

        #IN: path1='server_path1'. content1='contents1', path2='server_path2', content2='contents2' etc
        #OUT:{local_path=>server_path, local_path1=>server_path2 etc}
        def extract_personality(opts)
          personality_hash =  opts.inject({}) do |result, (opt_k,opt_v)|
            if opt_k.to_s =~ /^path([1-5]+)/
              tempfile = Tempfile.new("os_personality_local_#{$1}")
              tempfile.write(opts[:"content#{$1}"])
              result[tempfile.path]=opts[:"path#{$1}"]
            end
            result
          end
        end

        def api_v2
          if api_provider =~ /.*v2.0/
            true
          else
            false
          end
        end

        exceptions do

          on /Exception::BadRequest/ do
            status 400
          end

          on /Exception::Authentication/ do
            status 401
          end

          on /Exception::ItemNotFound/ do
            status 404
          end

        end


      end
    end
  end
end
