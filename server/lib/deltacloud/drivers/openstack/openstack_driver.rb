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

require 'openstack'
require 'tempfile'
require 'base64'

module Deltacloud
  module Drivers
    module Openstack
      class OpenstackDriver < Deltacloud::BaseDriver

        feature :instances, :user_name
        feature :instances, :authentication_key
        feature :instances, :authentication_password
        feature :instances, :user_files
        feature :instances, :user_data
        feature :images, :user_name
        feature :keys, :import_key
        feature :storage_volumes, :volume_name
        feature :storage_volumes, :volume_description

        define_instance_states do
          start.to( :pending )          .on( :create )
          pending.to( :running )        .automatically
          running.to( :running )        .on( :reboot )
          running.to( :stopping )       .on( :stop )
          stopping.to( :stopped )       .automatically
          stopped.to( :finish )         .automatically
          error.from(:running, :pending, :stopping)
        end

        define_hardware_profile('default')

        def supported_collections(credentials)
          #get the collections as defined by 'capability' and 'respond_to?' blocks
          super_collections = super
          begin
             new_client(credentials, "object-store")
          rescue Deltacloud::Exceptions::NotImplemented #OpenStack::Exception::NotImplemented...
             super_collections = super_collections - [Sinatra::Rabbit::BucketsCollection]
          end
          begin
              new_client(credentials, "volume")
          rescue Deltacloud::Exceptions::NotImplemented
              super_collections = super_collections - [Sinatra::Rabbit::StorageVolumesCollection]
          end
          super_collections
        end

        def hardware_profiles(credentials, opts = {})
          os = new_client(credentials)
          results = []
          safely do
            if opts[:id]
              begin
                flavor = os.flavor(opts[:id])
                results << convert_from_flavor(flavor)
              rescue => e
                raise e unless e.message =~ /The resource could not be found/
                results = []
              end
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
              begin
                img = os.get_image(opts[:id])
                results << convert_from_image(img, os.connection.authuser)
              rescue => e
                raise e unless e.message =~ /Image not found/
                results = []
              end
            else
              results = os.list_images.collect do |i|
                convert_from_image(i, os.connection.authuser)
              end
            end
          end
          results.each { |img| img.hardware_profiles = profiles }
          filter_on(results, :owner_id, opts)
        end

        def create_image(credentials, opts)
          os = new_client(credentials)
          safely do
            server = os.get_server(opts[:id])
            image_name = opts[:name] || "#{server.name}_#{Time.now}"
            img = server.create_image(:name=>image_name)
            convert_from_image(img, os.connection.authuser)
          end
        end

        def destroy_image(credentials, image_id)
          os = new_client(credentials)
          begin
            image = os.get_image(image_id)
            image.delete!
          rescue
            raise Deltacloud::Exceptions.exception_from_status(500, "Cannot delete image with id #{image_id}")
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
          return [] if opts[:id] and opts[:id] != 'default'
          [ Realm.new( { :id=>'default',
                        :name=>'default',
                        :limit => limits,
                        :state=>'AVAILABLE' })]
        end

        def instances(credentials, opts={})
          os = new_client(credentials)
          insts = attachments = []
          safely do
            if opts[:id]
              begin
                server = os.get_server(opts[:id])
                insts << convert_from_server(server, os.connection.authuser, get_attachments(opts[:id], os))
              rescue => e
                raise e unless e.message =~ /The resource could not be found/
                insts = []
              end
            else
              insts = os.list_servers_detail.collect do |s|
                convert_from_server(s, os.connection.authuser,get_attachments(s[:id], os))
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
          params = {}
          params[:personality] = extract_personality(opts)
          params[:name] = (opts[:name] && opts[:name].length>0)? opts[:name] : "server#{Time.now.to_s}"
          params[:imageRef] = image_id
          params[:flavorRef] =  (opts[:hwp_id] && opts[:hwp_id].length>0) ?
                          opts[:hwp_id] : hardware_profiles(credentials).first.id
          if opts[:password] && opts[:password].length > 0
            params[:adminPass]=opts[:password]
          end
          if opts[:keyname] && opts[:keyname].length > 0
            params[:key_name]=opts[:keyname]
          end
          if opts[:user_data] && opts[:user_data].length > 0
            params[:user_data]=Base64.encode64(opts[:user_data])
          end
          safely do
            server = os.create_server(params)
            result = convert_from_server(server, os.connection.authuser, get_attachments(server.id, os))
          end
          result
        end

        def reboot_instance(credentials, instance_id)
          os = new_client(credentials)
          safely do
            server = os.get_server(instance_id)
            server.reboot! # sends a hard reboot (power cycle) - could instead server.reboot("SOFT")
            convert_from_server(server, os.connection.authuser, get_attachments(instance_id, os))
          end
        end

        def destroy_instance(credentials, instance_id)
          os = new_client(credentials)
          server = instance = nil
          safely do
            server = os.get_server(instance_id)
            server.delete!
          end
          begin
            server.populate
            instance = convert_from_server(server, os.connection.authuser)
          rescue OpenStack::Exception::ItemNotFound
            instance = convert_from_server(server, os.connection.authuser)
            instance.state = "STOPPED"
          end
          instance
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
          os = new_client(credentials, "object-store")
          buckets = []
          safely do
            if opts[:id]
              buckets << convert_bucket(os.container(opts[:id]))
            else
              os.containers.each{|bucket_name| buckets << convert_bucket(os.container(bucket_name))}
            end
          end
          buckets
        end

        def create_bucket(credentials, name, opts={})
          os = new_client(credentials, "object-store")
          bucket = nil
          safely do
            bucket = os.create_container(name)
          end
          convert_bucket(bucket)
        end

        def delete_bucket(credentials, name, opts={})
          os = new_client(credentials, "object-store")
          safely do
            os.delete_container(name)
          end
        end

        def blobs(credentials, opts={})
          os = new_client(credentials, "object-store")
          blobs = []
          safely do
            bucket = os.container(opts['bucket'])
            if(opts[:id])
              blobs << convert_blob(bucket.object(opts[:id]), opts['bucket'])
            else
              bucket.objects_detail.each{|blob| blobs << convert_blob(blob, opts['bucket'])}
            end
          end
          blobs
        end

        def blob_data(credentials, bucket, blob, opts={})
          os = new_client(credentials, "object-store")
          safely do
            os.container(bucket).object(blob).data_stream do |chunk|
              yield chunk
            end
          end
        end

        def create_blob(credentials, bucket, blob, data, opts={})
          os = new_client(credentials, "object-store")
          safely do
            if(opts[:segment_manifest]) # finalize a segmented blob upload
              os_blob = os.container(bucket).create_object(blob, {:manifest=>"#{bucket}/#{opts[:segmented_blob_id]}"})
            else
              BlobHelper.rename_metadata_headers(opts, "X-Object-Meta-")
              os_blob = os.container(bucket).create_object(blob, {:content_type=> data[:type], :metadata=>opts}, data[:tempfile])
            end
            convert_blob(os_blob, bucket)
          end
        end

        def delete_blob(credentials, bucket, blob, opts={})
          os = new_client(credentials, "object-store")
          safely do
            os.container(bucket).delete_object(blob)
          end
        end

        def blob_metadata(credentials, opts={})
          os = new_client(credentials, "object-store")
          safely do
            os.container(opts['bucket']).object(opts[:id]).metadata
          end
        end

        def update_blob_metadata(credentials, opts={})
          os = new_client(credentials, "object-store")
          safely do
            BlobHelper.rename_metadata_headers(opts["meta_hash"], "")
            blob = os.container(opts['bucket']).object(opts[:id])
            blob.set_metadata(opts['meta_hash'])
          end
        end

        def init_segmented_blob(credentials, opts={})
          opts[:id]
        end

        def blob_segment_id(request, response)
          #could be in http header OR query string:
          segment_order = BlobHelper.segment_order(request)
          blob_name = request.env["PATH_INFO"].gsub(/(&\w*=\w*)*$/, "").split("/").pop
          "#{blob_name}#{segment_order}"
        end

        #params: {:user,:password,:bucket,:blob,:content_type,:content_length,:metadata}
        #params[:context] holds the request object - for getting to blob segment params
        def blob_stream_connection(params)
          if BlobHelper.segmented_blob_op_type(params[:context]) == "segment"
            params[:blob] = "#{params[:blob]}#{BlobHelper.segment_order(params[:context])}"
          end
          tokens = params[:user].split("+")
          user_name, tenant_name = tokens.first, tokens.last
          #need a client for the auth_token and endpoints
          os = OpenStack::Connection.create(:username => user_name, :api_key => params[:password], :authtenant => tenant_name, :auth_url => api_provider, :service_type => "object-store")
          http = Net::HTTP.new(os.connection.service_host, os.connection.service_port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          path = os.connection.service_path + URI.encode("/#{params[:bucket]}/#{params[:blob]}")
          request = Net::HTTP::Put.new(path)
          request['X-Auth-Token'] = os.connection.authtoken
          request['X-Storage-Token'] = os.connection.authtoken
          request['Connection'] = "Keep-Alive"
          request['Content-Type'] = params[:content_type]
          request['Content-Length'] = params[:content_length]
          request['Expect'] = "100-continue"
          metadata = params[:metadata] || {}
          BlobHelper::rename_metadata_headers(metadata, 'X-Object-Meta-')
          metadata.each{|k,v| request[k] = v}
          return http, request
        end

        def keys(credentials, opts={})
          os = new_client(credentials)
          keys = []
          safely do
            os.keypairs.values.each{|key| keys << convert_key(key)}
          end
          filter_on(keys, :id, opts)
        end

        def create_key(credentials, opts={})
          os = new_client(credentials)
          safely do
            params = (opts[:public_key] and opts[:public_key].length > 0)? {:name=>opts[:key_name], :public_key=> opts[:public_key]} : {:name=>opts[:key_name]}
            convert_key(os.create_keypair(params))
          end
        end

        def destroy_key(credentials, opts={})
          os = new_client(credentials)
          safely do
            os.delete_keypair(opts[:id])
          end
        end

        def storage_volumes(credentials, opts={})
          vs = new_client(credentials, "volume")
          volumes = []
          safely do
            if opts[:id]
              volumes <<  convert_volume(vs.get_volume(opts[:id]))
            else
              vs.volumes.each do |vol|
                volumes << convert_volume(vol)
              end
            end
          end
          volumes
        end

        def create_storage_volume(credentials, opts=nil)
          vs = new_client(credentials, "volume")
          params = {}
          safely do
            params[:size] = opts.delete("capacity") || 1
            params[:display_name] = opts.delete("name") || "Volume#{Time.now}"
            params[:display_description] = opts.delete("description") || params[:display_name]
            params[:availability_zone] = opts.delete("realm_id") unless (opts["realm_id"].nil? || opts["realm_id"].empty?)
            opts.delete("commit")
            opts.delete("snapshot_id") #FIXME AFTER ADDING SNAPSHOTS TO OPENSTACK GEM
            volume = convert_volume(vs.create_volume(opts.merge(params)))
          end
        end

        def destroy_storage_volume(credentials, opts={})
          vs = new_client(credentials, "volume")
          safely do
            vs.delete_volume(opts[:id])
          end
        end

        def attach_storage_volume(credentials, opts={})
          vs = new_client(credentials, "volume")
          cs = new_client(credentials, "compute")
          safely do
            cs.attach_volume(opts[:instance_id], opts[:id], opts[:device])
            volume = convert_volume(vs.get_volume(opts[:id]))
          end
        end

        def detach_storage_volume(credentials, opts={})
          vs = new_client(credentials, "volume")
          cs = new_client(credentials, "compute")
          safely do
            cs.detach_volume(opts[:instance_id], opts[:id])
            volume = convert_volume(vs.get_volume(opts[:id]))
          end
        end

        def storage_snapshots(credentials, opts={})
          vs = new_client(credentials, "volume")
          safely do
          end
        end

        def create_storage_snapshot(credentials, opts={})
          vs = new_client(credentials, "volume")
          safely do
          end
        end

        def destroy_storage_snapshot(credentials, opts={})
          vs = new_client(credentials, "volume")
          safely do
          end
        end

private

        #for v2 authentication credentials.name == "username+tenant_name"
        def new_client(credentials, type = "compute")
          tokens = credentials.user.split("+")
          if credentials.user.empty?
            raise AuthenticationFailure.new(Exception.new("Error: you must supply the username"))
          end
          if (tokens.size != 2 && api_v2)
            raise ValidationFailure.new(Exception.new("Error: expected \"username+tenantname\" as username, you provided: #{credentials.user}"))
          else
            user_name, tenant_name = tokens.first, tokens.last
          end
          safely do
            raise ValidationFailure.new(Exception.new("Error: tried to initialise Openstack connection using" +
                    " an unknown service_type: #{type}")) unless ["volume", "compute", "object-store"].include? type
            OpenStack::Connection.create(:username => user_name, :api_key => credentials.password, :authtenant => tenant_name, :auth_url => api_provider, :service_type => type)
           end
        end

#NOTE: for the convert_from_foo methods below... openstack-compute
#gives Hash for 'flavors' but OpenStack::Compute::Flavor for 'flavor'
#hence the use of 'send' to deal with both cases and save duplication

        def convert_from_flavor(flavor)
          op = (flavor.class == Hash)? :fetch : :send
          hwp = HardwareProfile.new(flavor.send(op, :id).to_s) do
            architecture 'x86_64'
            memory flavor.send(op, :ram).to_i
            storage flavor.send(op, :disk).to_i
            cpu flavor.send(op, :vcpus).to_i
          end
          hwp.name = flavor.send(op, :name)
          return hwp
        end

        def convert_from_image(image, owner)
          op = (image.class == Hash)? :fetch : :send
          Image.new({
                    :id => image.send(op, :id),
                    :name => image.send(op, :name),
                    :description => image.send(op, :name),
                    :owner_id => owner,
                    :state => image.send(op, :status),
                    :architecture => 'x86_64',
                    :creation_time => image.send(op, :created)
                    })
        end

        def convert_from_server(server, owner, attachments=[])
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
            :state => convert_instance_state(server.send(op, :status).downcase),
            :architecture => 'x86_64',
            :image_id => image[:id] || image["id"],
            :instance_profile => InstanceProfile::new(flavor[:id] || flavor["id"]),
            :public_addresses => convert_server_addresses(server, :public),
            :private_addresses => convert_server_addresses(server, :private),
            :username => 'root',
            :password => password,
            :keyname => server.send(op, :key_name),
            :storage_volumes => attachments.inject([]){|res, cur| res << {cur[:volumeId] => cur[:device]} ;res}
          )
          inst.actions = instance_actions_for(inst.state)
          inst.create_image = 'RUNNING'.eql?(inst.state)
          inst
        end

        def convert_instance_state(openstack_state)
          case openstack_state
            when /.*reboot/
              "PENDING"
            when /.*deleting/
              "STOPPING"
            when /.*deleted/
              "STOPPED"
            when /build.*$/
              "PENDING"
            when /error.*/
              "ERROR"
            when /active/
              "RUNNING"
            else
              "UNKNOWN"
          end
        end

        def convert_server_addresses(server, type)
          op, address_label = (server.class == Hash)? [:fetch, :addr] : [:send, :address]
          addresses = (server.send(op, :addresses)[type] || []).collect do |addr|
            type = (addr.send(op, :version) == 4)? :ipv4 : :ipv6
            InstanceAddress.new(addr.send(op, address_label), {:type=>type} )
          end
        end

        def convert_bucket(bucket)
          Bucket.new({ :id => bucket.name,
                       :name => bucket.name,
                       :size => bucket.count,
                       :blob_list => bucket.objects })
        end

        def convert_blob(blob, bucket_name)
          op, blob_meta = (blob.class == Hash)? [:fetch, {}] : [:send, blob.metadata]
          Blob.new({   :id => blob.send(op, :name),
                       :bucket => bucket_name,
                       :content_length => blob.send(op, :bytes),
                       :content_type => blob.send(op, :content_type),
                       :last_modified => blob.send(op, :last_modified),
                       :user_metadata => blob_meta })
        end

        def convert_key(key)
          Key.new(
            :id => key[:name],
            :fingerprint => key[:fingerprint],
            :credential_type => :key,
            :pem_rsa_key => key[:private_key], # only available once, on create_key
            :state => "AVAILABLE"
          )
        end

        def get_attachments(server_id, client)
          if client.api_extensions[:"os-volumes"]
            attachments = client.list_attachments(server_id)
            attachments[:volumeAttachments] || []
          else
            []
          end
        end

        def convert_volume(vol)
          StorageVolume.new({ :id => vol.id,
                              :name => vol.display_name,
                              :created => vol.created_at,
                              :state => (vol.attachments.inject([]){|res, cur| res << cur if cur.size > 0 ; res}.empty?) ? "AVAILABLE" : "IN-USE",
                              :capacity => vol.size,
                              :instance_id => (vol.attachments.first["serverId"] unless vol.attachments.empty?),
                              :device => (vol.attachments.first["device"] unless vol.attachments.empty?),
                              :realm_id => vol.availability_zone,
                              :description => vol.display_description # openstack volumes have a display_description attr
          })
        end

        #IN: path1='server_path1'. content1='contents1', path2='server_path2', content2='contents2' etc
        #OUT:{local_path=>server_path, local_path1=>server_path2 etc}
        def extract_personality(opts)
          personality_hash =  opts.inject({}) do |result, (opt_k,opt_v)|
            if (opt_k.to_s =~ /^path([1-5]+)/ and opts[opt_k] != nil and opts[opt_k].length > 0)
              unless opts[:"content#{$1}"].nil?
                case opts[:"content#{$1}"]
                  when String
                    tempfile = Tempfile.new("os_personality_local_#{$1}")
                    tempfile.write(opts[:"content#{$1}"])
                    result[tempfile.path]=opts[:"path#{$1}"]
                  when Hash
                    result[opts[:"content#{$1}"][:tempfile].path]=opts[:"path#{$1}"]
                end
              end
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

          on /(Exception::BadRequest|PersonalityFilePathTooLong|PersonalityFileTooLarge|TooManyPersonalityItems)/ do
            status 400
          end

          on /Must supply a :username/ do
            status 401
          end

          on /OpenStack::Exception::Authentication/ do
            status 401
          end

          on /OpenStack::Exception::ItemNotFound/ do
            status 404
          end

          on /Exception::Other/ do
            status 500
          end

          on /OpenStack::Exception::NotImplemented/ do
            status 501
          end

        end


      end
    end
  end
end
