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

require 'cloudfiles'
require 'cloudservers'

require_relative 'anti_cache_monkey_patch'

module Deltacloud
  module Drivers
    module Rackspace

class RackspaceDriver < Deltacloud::BaseDriver

  feature :instances, :user_name
  feature :instances, :authentication_password
  feature :instances, :user_files
  feature :images, :user_name

  define_hardware_profile('default')

  def hardware_profiles(credentials, opts = {})
    rs = new_client( credentials )
    results = []
    safely do
      results = rs.list_flavors.collect do |f|
        HardwareProfile.new(f[:id].to_s) do
          architecture 'x86_64'
          memory f[:ram].to_i
          storage f[:disk].to_i
        end
      end
    end
    filter_hardware_profiles(results, opts)
  end

  def images(credentials, opts=nil)
    rs = new_client(credentials)
    results = []
    safely do
      results = rs.list_images.collect do |img|
        Image.new(
          :id => img[:id].to_s,
          :name => img[:name],
          :description => img[:name],
          :owner_id => credentials.user,
          :state => img[:status],
          :architecture => 'x86_64'
        )
      end
    end
    profiles = hardware_profiles(credentials)
    results.each { |img| img.hardware_profiles = profiles }
    filter_on( results, :id, opts )
  end

  #rackspace does not at this stage have realms... its all US/TX, all the time (at least at time of writing)
  def realms(credentials, opts=nil)
    [Realm.new( {
      :id=>"us",
      :name=>"United States",
      :state=> "AVAILABLE"
    } )]
  end

  #
  # create instance. Default to flavor 1 - really need a name though...
  # In rackspace, all flavors work with all images.
  #
  def create_instance(credentials, image_id, opts)
    rs = new_client( credentials )
    result = nil
    params = extract_personality(opts)
    params[:name] = opts[:name] || Time.now.to_s
    params[:imageId] = image_id.to_i
    params[:flavorId] = (opts[:hwp_id] && opts[:hwp_id].length>0) ? opts[:hwp_id].to_i : 1
    safely do
      server = rs.create_server(params)
      result = convert_instance_after_create(server, credentials.user, server.adminPass)
    end
    result
  end

  def create_image(credentials, opts={})
    rs = new_client(credentials)
    safely do
      server = rs.get_server(opts[:id].to_i)
      image = server.create_image(opts[:name])
      Image.new(
        :id => image.id.to_s,
        :name => opts[:name] || image.name,
        :description => opts[:description] || image.description,
        :owner_id => credentials.user,
        :state => image.status,
        :architecture => 'x86_64'
      )
    end
  end

  def destroy_image(credentials, image_id)
    rax_client = new_client(credentials)
    safely do
      image = rax_client.get_image(image_id.to_i)
      unless image.delete!
        raise "ERROR: Cannot delete image with ID:#{image_id}"
      end
    end
  end

  def run_on_instance(credentials, opts={})
    target = instance(credentials, :id => opts[:id])
    param = {}
    param[:credentials] = {
      :username => 'root',
      :password => opts[:password]
    }
    param[:port] = opts[:port] || '22'
    param[:ip] = opts[:ip] || target.public_addresses.first.address
    safely do
      Deltacloud::Runner.execute(opts[:cmd], param)
    end
  end

  def reboot_instance(credentials, instance_id)
    rs = new_client(credentials)
    safely do
      server = rs.get_server(instance_id.to_i)
      server.reboot!
      convert_instance_after_create(server, credentials.user)
    end
  end

  def destroy_instance(credentials, instance_id)
    rs = new_client(credentials)
    safely do
      server = rs.get_server(instance_id.to_i)
      server.delete!
      convert_instance_after_create(server, credentials.user)
    end
  end

  alias_method :stop_instance, :destroy_instance

  #
  # Instances
  #
  def instances(credentials, opts={})

    rs = new_client(credentials)
    insts = []

    safely do
      begin
        if opts[:id]
          server = rs.get_server(opts[:id].to_i)
          insts << convert_instance_after_create(server, credentials.user)
        else
          insts = rs.list_servers_detail.collect do |server|
            convert_instance(server, credentials.user)
          end
        end
      rescue CloudServers::Exception::ItemNotFound
      end
    end

    insts = filter_on( insts, :id, opts )
    insts = filter_on( insts, :state, opts )
    insts
  end

  define_instance_states do
    start.to( :pending )          .on( :create )
    pending.to( :running )        .automatically
    running.to( :running )        .on( :reboot )
    running.to( :stopping )  .on( :stop )
    stopping.to( :stopped )  .automatically
    stopped.to( :finish )         .automatically
  end

#--
# Buckets
#--
  def buckets(credentials, opts = {})
    bucket_list = []
    cf = cloudfiles_client(credentials)
    safely do
      unless (opts[:id].nil?)
        bucket = cf.container(opts[:id])
        bucket_list << convert_container(bucket)
      else
        cf.containers.each do |container_name|
          bucket_list << Bucket.new({:id => container_name, :name => container_name})
        end #containers.each
      end #unless
    end #safely
    filter_on(bucket_list, :id, opts)
  end

#--
# Create Bucket
#--
  def create_bucket(credentials, name, opts = {})
    bucket = nil
    cf = cloudfiles_client(credentials)
    safely do
      new_bucket = cf.create_container(name)
      bucket = convert_container(new_bucket)
    end
    bucket
  end

#--
# Delete Bucket
#--
  def delete_bucket(credentials, name, opts = {})
    cf = cloudfiles_client(credentials)
    safely do
      cf.delete_container(name)
    end
  end

#--
# Blobs
#--
  def blobs(credentials, opts = {})
    cf = cloudfiles_client(credentials)
    blobs = []
    safely do
      cf_container = cf.container(opts['bucket'])
      cf_container.objects.each do |object_name|
        blobs << convert_object(cf_container.object(object_name))
      end
    end
    blobs = filter_on(blobs, :id, opts)
    blobs
  end

#-
# Blob data
#-
  def blob_data(credentials, bucket_id, blob_id, opts = {})
    cf = cloudfiles_client(credentials)
    cf.container(bucket_id).object(blob_id).data_stream do |chunk|
      yield chunk
    end
  end

#--
# Create Blob
#--
  def create_blob(credentials, bucket_id, blob_id, blob_data, opts={})
    cf = cloudfiles_client(credentials)
    #insert ec2-specific header for user metadata ... X-Object-Meta-KEY = VALUE
    BlobHelper::rename_metadata_headers(opts, "X-Object-Meta-")
    opts['Content-Type'] = blob_data[:type]
    object = nil
    safely do
      #must first create the object using cloudfiles_client.create_object
      #then can write using object.write(data)
      object = cf.container(bucket_id).create_object(blob_id)
      #blob_data is a construct with data in .tempfile and content-type in {:type}
      res = object.write(blob_data[:tempfile], opts)
    end
    Blob.new( { :id => object.name,
                :bucket => object.container.name,
                :content_length => blob_data[:tempfile].length,
                :content_type => blob_data[:type],
                :last_modified => '',
                :user_metadata => opts.select{|k,v| k.match(/^X-Object-Meta-/i)}
              }
            )
  end

#--
# Delete Blob
#--
  def delete_blob(credentials, bucket_id, blob_id, opts={})
    cf = cloudfiles_client(credentials)
    safely do
      cf.container(bucket_id).delete_object(blob_id)
    end
  end

#-
# Blob Metadada
#-
  def blob_metadata(credentials, opts = {})
    cf = cloudfiles_client(credentials)
    meta = {}
    safely do
      meta = cf.container(opts['bucket']).object(opts[:id]).metadata
    end
    meta
  end

#-
# Update Blob Metahash
#-
  def update_blob_metadata(credentials, opts={})
    cf = cloudfiles_client(credentials)
    meta_hash = opts['meta_hash']
    #the set_metadata method actually places the 'X-Object-Meta-' prefix for us:
    BlobHelper::rename_metadata_headers(meta_hash, '')
    safely do
      blob = cf.container(opts['bucket']).object(opts[:id])
      blob.set_metadata(meta_hash)
    end
  end

  #params: {:user,:password,:bucket,:blob,:content_type,:content_length,:metadata}
  def blob_stream_connection(params)
    #create a cloudfiles connection object to get the authtoken
    cf, cf_host, cf_path, cf_authtoken = nil
    safely do
      cf = CloudFiles::Connection.new(:username => params[:user],
                                :api_key => params[:password])
      cf_authtoken = cf.authtoken
      cf_host = cf.storagehost
      cf_path = cf.storagepath
    end
    provider = "https://#{cf_host}"
    uri = URI.parse(provider)
    http = Net::HTTP.new(uri.host, uri.port )
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Put.new("#{cf_path}/#{params[:bucket]}/#{params[:blob]}")
    request['Host'] = "#{cf_host}"
    request['X-Auth-Token'] = "#{cf_authtoken}"
    request['Content-Type'] = params[:content_type]
    request['Content-Length'] = params[:content_length]
    request['Expect'] = "100-continue"
    metadata = params[:metadata] || {}
    BlobHelper::rename_metadata_headers(metadata, 'X-Object-Meta-')
    metadata.each{|k,v| request[k] = v}
    return http, request
  end

  private

  def new_client(credentials)
    safely do
      CloudServers::Connection.new(:username => credentials.user, :api_key => credentials.password)
    end
  end

  def convert_container(cf_container)
    blob_list=cf_container.objects
    Bucket.new({ :id => cf_container.name,
                    :name => cf_container.name,
                    :size => blob_list.size,
                    :blob_list => blob_list
                 })
  end

  def convert_object(cf_object)
    Blob.new({   :id => cf_object.name,
                 :bucket => cf_object.container.name,
                 :content_length => cf_object.bytes,
                 :content_type => cf_object.content_type,
                 :last_modified => cf_object.last_modified,
                 :user_metadata => cf_object.metadata
              })
  end

  def convert_instance_after_create(server, user_name, password='')
    inst = Instance.new(
      :id => server.id.to_s,
      :realm_id => 'us',
      :owner_id => user_name,
      :description => server.name,
      :name => server.name,
      :state => (server.status == 'ACTIVE') ? 'RUNNING' : 'PENDING',
      :architecture => 'x86_64',
      :image_id => server.imageId.to_s,
      :instance_profile => InstanceProfile::new(server.flavorId.to_s),
      :public_addresses => server.addresses[:public].collect { |ip| InstanceAddress.new(ip) },
      :private_addresses => server.addresses[:private].collect { |ip| InstanceAddress.new(ip) },
      :username => 'root',
      :password => password ? password : nil
    )
    inst.actions = instance_actions_for(inst.state)
    inst.create_image = 'RUNNING'.eql?(inst.state)
    inst
  end

  def convert_instance(server, user_name = '')
    inst = Instance.new(
      :id => server[:id].to_s,
      :realm_id => 'us',
      :owner_id => user_name,
      :description => server[:name],
      :name => server[:name],
      :state => (server[:status] == 'ACTIVE') ? 'RUNNING' : 'PENDING',
      :architecture => 'x86_64',
      :image_id => server[:imageId].to_s,
      :instance_profile => InstanceProfile::new(server[:flavorId].to_s),
      :public_addresses => server[:addresses][:public].collect { |ip| InstanceAddress.new(ip) },
      :private_addresses => server[:addresses][:private].collect { |ip| InstanceAddress.new(ip) }
    )
    inst.create_image = 'RUNNING'.eql?(inst.state)
    inst.actions = instance_actions_for(inst.state)
    inst
  end

  def cloudfiles_client(credentials)
    safely do
      CloudFiles::Connection.new(:username => credentials.user, :api_key => credentials.password)
    end
  end

  exceptions do

    on /No offering found/ do
      status 400
    end

    on /Authentication failed/ do
      status 401
    end

    on /Error/ do
      status 500
    end

    on /CloudServers::Exception::(\w+)/ do
      status 500
    end

  end

  private

  def extract_personality(opts)
    # This relies on an undocumented feature of the cloudservers gem:
    # create_server allows passing in strings for the file contents
    # directly if :personality maps to an array of hashes
    ary = opts.inject([]) do |a, e|
      k, v = e
      if k.to_s =~ /^path([0-9]+)/
        a << {
          :path => v,
          :contents => Base64.decode64(opts[:"content#{$1}"])
        }
      end
      a
    end
    if ary.empty?
      {}
    else
      { :personality => ary }
    end
  end
end

    end
  end
end
