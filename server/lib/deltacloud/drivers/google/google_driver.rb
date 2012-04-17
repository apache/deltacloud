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

require 'fog'

module Deltacloud
  module Drivers
    module Google

class GoogleDriver < Deltacloud::BaseDriver

  feature :buckets, :bucket_location

#--
# Buckets
#--
  def buckets(credentials, opts={})
    buckets = []
    google_client = new_client(credentials)
    safely do
      if opts[:id]
        bucket = google_client.get_bucket(opts[:id])
        buckets << convert_bucket(bucket.body)
      else
        google_client.get_service.body['Buckets'].each do |bucket|
          buckets << Bucket.new({:name => bucket['Name'], :id => bucket['Name']})
        end
      end
    end
    buckets = filter_on(buckets, :id, opts)
  end

#--
# Create bucket - valid values for location {'EU','US'}
#--
  def create_bucket(credentials, name, opts={})
    google_client = new_client(credentials)
    safely do
      bucket_location = opts['location']
      if (bucket_location && bucket_location.size > 0)
        res = google_client.put_bucket(name, {"LocationConstraint" => opts['location']})
      else
        google_client.put_bucket(name)
      end
      #res.status should be eql 200 - but fog will explode if not all ok...
      Bucket.new({ :id => name,
                   :name => name,
                   :size => 0,
                   :blob_list => [] })
    end
  end

#--
# Delete bucket
#--
  def delete_bucket(credentials, name, opts={})
    google_client = new_client(credentials)
    safely do
      google_client.delete_bucket(name)
    end
  end

#--
# Blobs
#--
  def blobs(credentials, opts={})
    blobs = []
    google_client = new_client(credentials)
    safely do
      google_blob = google_client.head_object(opts['bucket'], opts[:id]).headers
      meta_hash = google_blob.inject({}){|result, (k,v)| result[k]=v if k=~/^x-goog-meta-/i ; result}
      meta_hash.gsub_keys("x-goog-meta-", "")
      blobs << Blob.new({   :id => opts[:id],
                 :bucket => opts['bucket'],
                 :content_length => google_blob['Content-Length'],
                 :content_type => google_blob['Content-Type'],
                 :last_modified => google_blob['Last-Modified'],
                 :user_metadata => meta_hash
              })

    end
    blobs
  end

  def blob_data(credentials, bucket_id, blob_id, opts={})
    google_client = new_client(credentials)
    safely do
      google_client.get_object(bucket_id, blob_id) do |chunk|
        yield chunk
      end
    end
  end

#--
# Create Blob
#--
  def create_blob(credentials, bucket_id, blob_id, blob_data, opts={})
    google_client = new_client(credentials)
    safely do
      dcloud_blob_metadata = BlobHelper::extract_blob_metadata_hash(opts)
      BlobHelper::rename_metadata_headers(opts, 'x-goog-meta-')
      opts['Content-Type'] = blob_data[:type]
      google_client.put_object(bucket_id, blob_id, blob_data[:tempfile], opts)
      Blob.new({ :id => blob_id,
                 :bucket => bucket_id,
                 :content_length => File.size(blob_data[:tempfile]).to_s,
                 :content_type => blob_data[:type],
                 :last_modified => "",
                 :user_metadata => dcloud_blob_metadata  })
    end
  end

  #params: {:user,:password,:bucket,:blob,:content_type,:content_length,:metadata}
  def blob_stream_connection(params)
    client = Fog::Storage.new({:provider => :google, :google_storage_access_key_id => params[:user],
                               :google_storage_secret_access_key => params[:password]})
    google_request_uri = "https://#{client.instance_variable_get(:@host)}"
    uri = URI.parse(google_request_uri)
    conn_params = {} # build hash for the Fog signature method
    conn_params[:headers] = {} #put the metadata here
    conn_params[:host] = uri.host
    conn_params[:path] = "#{params[:bucket]}/#{CGI.escape(params[:blob])}"
    conn_params[:method] = "PUT"
    timestamp = Fog::Time.now.to_date_header
    conn_params[:headers]['Date'] = timestamp
    conn_params[:headers]['Content-Type'] = params[:content_type]
    metadata = params[:metadata] || {}
    BlobHelper::rename_metadata_headers(metadata, 'x-goog-meta-')
    metadata.each{|k,v| conn_params[:headers][k]=v}
    auth_string = "GOOG1 #{params[:user]}:#{client.signature(conn_params)}"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Put.new("/#{conn_params[:path]}")
    request['Host'] = conn_params[:host]
    request['Date'] = conn_params[:headers]['Date']
    request['Content-Type'] = conn_params[:headers]['Content-Type']
    request['Content-Length'] = params[:content_length]
    request['Authorization'] = auth_string
    metadata.each{|k,v| request[k] = v}
    return http, request
  end

#--
# Delete Blob
#--
  def delete_blob(credentials, bucket_id, blob_id, opts={})
    google_client = new_client(credentials)
    safely do
      google_client.delete_object(bucket_id, blob_id)
    end
  end

#-
# Blob Metadada
#-
  def blob_metadata(credentials, opts = {})
    google_client = new_client(credentials)
    safely do
      google_blob = google_client.head_object(opts['bucket'], opts[:id]).headers
      meta_hash = google_blob.inject({}){|result, (k,v)| result[k]=v if k=~/^x-goog-meta-/i ; result}
      meta_hash.gsub_keys("x-goog-meta-", "")
    end
  end

#-
# Update Blob Metadata
#-
  def update_blob_metadata(credentials, opts={})
    google_client = new_client(credentials)
    safely do
      meta_hash = BlobHelper::rename_metadata_headers(opts['meta_hash'], 'x-goog-meta-')
      options = {'x-goog-metadata-directive'=>'REPLACE'}
      options.merge!(meta_hash)
      bucket = opts['bucket']
      blob = opts[:id]
      google_client.copy_object(bucket, blob, bucket, blob, options) #source,source,target,target,options
      meta_hash.gsub_keys("x-goog-meta-", "")
    end
  end

  def valid_credentials?(credentials)
    begin
      new_client(credentials)
    rescue
      return false
    end
    return true
  end

  private

  def new_client(credentials)
    safely do
      Fog::Storage.new({ :provider => :google, :google_storage_access_key_id => credentials.user,
                         :google_storage_secret_access_key => credentials.password})

    end
  end

  def convert_bucket(bucket)
    blob_list = []
    bucket['Contents'].each do |blob|
      blob_list << blob['Key']
    end
    Bucket.new({    :id => bucket['Name'],
                    :name => bucket['Name'],
                    :size => blob_list.size,
                    :blob_list => blob_list
                  })
  end

end

    end
  end
end
