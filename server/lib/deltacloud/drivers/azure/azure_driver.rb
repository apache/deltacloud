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

#Windows Azure (WAZ) gem at http://github.com/johnnyhalife/waz-storage
require 'deltacloud/base_driver'
require 'waz-blobs'

module Deltacloud
  module Drivers
    module Azure

class AzureDriver < Deltacloud::BaseDriver

  def supported_collections; [:buckets]
  end

#--
# Buckets
#--
  def buckets(credentials, opts={})
    buckets = []
    azure_connect(credentials)
    safely do
      unless (opts[:id].nil?)
        waz_bucket =  WAZ::Blobs::Container.find(opts[:id])
        buckets << convert_container(waz_bucket)
      else
        WAZ::Blobs::Container.list.each do |waz_container|
          buckets << Bucket.new({:id =>waz_container.name, :name => waz_container.name})
        end #container.list.each
      end #unless
    end #safely
    buckets = filter_on(buckets, :id, opts)
  end

#--
# Create bucket
#--
  def create_bucket(credentials, name, opts={})
    #for whatever reason, bucket names MUST be lowercase...
    #http://msdn.microsoft.com/en-us/library/dd135715.aspx
    name.downcase!
    bucket = nil
    azure_connect(credentials)
    safely do
      waz_container = WAZ::Blobs::Container.create(name)
      bucket = convert_container(waz_container)
    end
    bucket
  end

#--
# Delete bucket
#--
  def delete_bucket(credentials, name, opts={})
    azure_connect(credentials)
    safely do
      WAZ::Blobs::Container.find(name).destroy!
    end
  end

#--
# Blobs
#--
  def blobs(credentials, opts={})
    blob_list = []
    azure_connect(credentials)
    safely do
      the_bucket = WAZ::Blobs::Container.find(opts['bucket'])
      if(opts[:id])
        the_blob = the_bucket[opts[:id]]
        blob_list << convert_blob(the_blob) unless the_blob.nil?
      else
        the_bucket.blobs.each do |waz_blob|
          blob_list << convert_blob(waz_blob)
        end #each.do
      end #if
    end #safely do
    blob_list = filter_on(blob_list, :id, opts)
    blob_list
  end

  def blob_data(credentials, bucket_id, blob_id, opts={})
    azure_connect(credentials)
    # WAZ get blob data methods cant accept blocks for 'streaming'... FIXME
      yield WAZ::Blobs::Container.find(bucket_id)[blob_id].value
  end

#--
# Create Blob
#--
  def create_blob(credentials, bucket_id, blob_id, blob_data, opts={})
    azure_connect(credentials)
    #insert azure-specific header for user metadata ... x-ms-meta-kEY = VALUE
    BlobHelper::rename_metadata_headers(opts, "x-ms-meta-")
    safely do
      #get a handle to the bucket in order to put there
      the_bucket = WAZ::Blobs::Container.find(bucket_id)
      the_bucket.store(blob_id, blob_data[:tempfile], blob_data[:type], opts)
    end
    Blob.new( { :id => blob_id,
                :bucket => bucket_id,
                :content_lengh => blob_data[:tempfile].length,
                :content_type => blob_data[:type],
                :last_modified => '',
                :user_metadata => opts.gsub_keys(/x-ms-meta-/,'')
            } )
  end

#--
# Delete Blob
#--
  def delete_blob(credentials, bucket_id, blob_id, opts={})
    azure_connect(credentials)
    #get a handle to bucket and blob, and destroy!
    the_bucket = WAZ::Blobs::Container.find(bucket_id)
    the_blob = the_bucket[blob_id]
    the_blob.destroy!
  end

#-
# Blob Metadada
#-
  def blob_metadata(credentials, opts = {})
    azure_connect(credentials)
    all_meta = nil
    safely do
      blob = WAZ::Blobs::Container.find(opts['bucket'])[opts[:id]]
      return nil unless blob
      all_meta = blob.metadata
    end
    user_meta = {}
    all_meta.inject({}){|result_hash, (k,v)| user_meta[k]=v if k.to_s.match(/x_ms_meta/i)}
    user_meta.gsub_keys(/x_ms_meta_/,'')
  end

#-
# Update Blob Metadata
#-
  def update_blob_metadata(credentials, opts={})
    azure_connect(credentials)
    meta_hash = opts['meta_hash']
    BlobHelper::rename_metadata_headers(meta_hash, "x-ms-meta-")
    safely do
      the_blob = WAZ::Blobs::Container.find(opts['bucket'])[opts[:id]]
      the_blob.put_metadata!(meta_hash)
    end
  end


  private

  def azure_connect(credentials)
    options = {:account_name => credentials.user, :access_key => credentials.password}
    safely do
      WAZ::Storage::Base.establish_connection!(options)
    end
  end

  def convert_container(waz_container)
    blob_list = []
    waz_container.blobs.each do |blob|
      blob_list << blob.name
    end
    Bucket.new({ :id => waz_container.name,
                    :name => waz_container.name,
                    :size => blob_list.size,
                    :blob_list => blob_list
                  })
  end

  def convert_blob(waz_blob)
    url = waz_blob.url.split('/')
    bucket = url[url.length-2] #FIXME
    #get only user defined metadata
    blob_metadata = {}
    waz_blob.metadata.inject({}) { |result_hash, (k,v)| blob_metadata[k]=v if k.to_s.match(/x_ms_meta/i)}
    #strip off the x_ms_meta_ from each key
    blob_metadata.gsub_keys(/x_ms_meta_/, '')
    Blob.new({   :id => waz_blob.name,
                 :bucket => bucket,
                 :content_length => waz_blob.metadata[:content_length],
                 :content_type => waz_blob.metadata[:content_type],
                 :last_modified => waz_blob.metadata[:last_modified],
                 :user_metadata => blob_metadata
              })
  end


end

    end #module Azure
  end #module Drivers
end #module Deltacloud
