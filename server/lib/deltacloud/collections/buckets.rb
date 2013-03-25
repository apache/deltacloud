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

module Deltacloud::Collections
  class Buckets < Base

    include Deltacloud::Features

    set :capability, lambda { |m| driver.respond_to? m }

    check_features :for => lambda { |c, f| driver.class.has_feature?(c, f) }

    new_route_for :buckets

    get '/buckets/:bucket/%s' % NEW_BLOB_FORM_ID do
      @bucket_id = params[:bucket]
      respond_to do |format|
        format.html {haml :"blobs/new", :locals=>{:bucket_id => @bucket_id} }
      end
    end


    head '/buckets/:bucket/:blob' do
      @blob_id = params[:blob]
      @blob_metadata = driver.blob_metadata(credentials, {:id => params[:blob], 'bucket' => params[:bucket]})
      if @blob_metadata
        @blob_metadata.each do |k,v|
          headers["X-Deltacloud-Blobmeta-#{k}"] = v
        end
        status 204
        respond_to do |format|
          format.xml
          format.json
        end
      else
        report_error(404)
      end
    end

    put "/segmented_blob_operation/:bucket/:blob" do
      case BlobHelper.segmented_blob_op_type(request)
        when "init" then
          segmented_blob_id = driver.init_segmented_blob(credentials, {:id => params[:blob],
                                            :bucket => params[:bucket]})
          headers["X-Deltacloud-SegmentedBlob"] = segmented_blob_id
          status 204
        when "segment" then
          if env["BLOB_SUCCESS"] # set by blob_stream_helper after succesful stream PUT
            #segment already uploaded by blob_streaming_patch - setting blob_segment-id from the response
            headers["X-Deltacloud-BlobSegmentId"] = request.env["BLOB_SEGMENT_ID"] # set in blob_stream_helper: 203
            status 204
          else
            report_error(400) # likely blob size < 112 KB (didn't hit streaming patch)
          end
        when "finalize" then
          segmented_blob_manifest = BlobHelper.extract_segmented_blob_manifest(request)
          segmented_blob_id = BlobHelper.segmented_blob_id(request)
          @blob = driver.create_blob(credentials, params[:bucket], params[:blob], nil, {:segment_manifest=>segmented_blob_manifest, :segmented_blob_id=>segmented_blob_id})
          respond_to do |format|
            format.xml { haml :"blobs/show", :locals => { :blob => @blob } }
            format.html { haml :"blobs/show", :locals => { :blob => @blob } }
            format.json { xml_to_json 'blobs/show' }
          end
        else
          report_error(500)
      end
    end

    put "/buckets/:bucket/:blob" do
      if BlobHelper.segmented_blob(request)
        status, headers, body = call!(env.merge("PATH_INFO" => "/segmented_blob_operation/#{params[:bucket]}/#{params[:blob]}"))
      elsif(env["BLOB_SUCCESS"]) #ie got a 200ok after putting blob
        content_type = env["CONTENT_TYPE"]
        content_type ||=  ""
        @blob = driver.blob(credentials, {:id => params[:blob],
                                          'bucket' => params[:bucket]})
        respond_to do |format|
          format.xml { haml :"blobs/show", :locals => { :blob => @blob } }
          format.html { haml :"blobs/show", :locals => { :blob => @blob } }
          format.json { JSON::dump(:blob => @blob.to_hash(self) ) }
        end
      elsif(env["BLOB_FAIL"])
        report_error(500) #OK?
      else # small blobs - < 112kb dont hit the streaming monkey patch - use 'normal' create_blob
        # also, if running under webrick don't hit the streaming patch (Thin specific)
        bucket_id = params[:bucket]
        blob_id = params[:blob]
        temp_file = Tempfile.new("temp_blob_file")
        temp_file.write(env['rack.input'].read)
        temp_file.flush
        content_type = env['CONTENT_TYPE'] || ""
        blob_data = {:tempfile => temp_file, :type => content_type}
        user_meta = BlobHelper::extract_blob_metadata_hash(request.env)
        @blob = driver.create_blob(credentials, bucket_id, blob_id, blob_data, user_meta)
        temp_file.delete
        respond_to do |format|
          format.xml  { haml :"blobs/show", :locals => { :blob => @blob } }
          format.html { haml :"blobs/show", :locals => { :blob => @blob } }
          format.json { JSON::dump(:blob => @blob.to_hash(self)) }
        end
      end
    end


    collection :buckets do

      standard_show_operation
      standard_index_operation

      operation :create, :with_capability => :create_bucket do
        param :name,      :string,    :required
        control do
          @bucket = driver.create_bucket(credentials, params[:name], params)
          status 201
          response['Location'] = bucket_url(@bucket.id)
          respond_to do |format|
            format.xml  { haml :"buckets/show", :locals=> { :bucket => @bucket } }
            format.json { JSON::dump(:bucket => @bucket.to_hash(self)) }
            format.html do
              redirect bucket_url(@bucket.id) if @bucket and @bucket.id
              redirect buckets_url
            end
          end
        end
      end

      operation :destroy, :with_capability => :delete_bucket do
        control do
          driver.delete_bucket(credentials, params[:id], params)
          status 204
          respond_to do |format|
            format.xml
            format.json
            format.html {  redirect(buckets_url) }
          end
        end
      end

      collection :blobs, :with_id => :blob_id, :no_member => true do

        operation :show, :with_capability => :blob do
          param :blob_id, :string, :required
          control do
            @blob = driver.blob(credentials, { :id => params[:blob_id], 'bucket' => params[:id]} )
            if @blob
              respond_to do |format|
                format.xml { haml :"blobs/show", :locals => { :blob => @blob } }
                format.html { haml :"blobs/show", :locals => { :blob => @blob } }
                format.json { JSON::dump(:blob => @blob.to_hash(self)) }
              end
            else
              report_error(404)
            end
          end

        end

        operation :create, :with_capability => :create_blob do
          description "Create new blob"
          param :id, :string, :required, 'The bucket ID'
          param :blob_id,  :string,  :required
          param :blob_data, :hash, :required
          control do
            bucket_id = params[:id]
            blob_id = params['blob_id']
            blob_data = params['blob_data']
            user_meta = {}
            #metadata from params (i.e., passed by http form post, e.g. browser)
            max = params[:meta_params]
            if(max)
              (1..max.to_i).each do |i|
                key = params[:"meta_name#{i}"]
                key = "HTTP_X_Deltacloud_Blobmeta_#{key}"
                value = params[:"meta_value#{i}"]
                user_meta[key] = value
              end
            end
            @blob = driver.create_blob(credentials, bucket_id, blob_id, blob_data, user_meta)
            status 201
            respond_to do |format|
              format.xml { haml :"blobs/show", :locals => { :blob => @blob } }
              format.html { haml :"blobs/show", :locals => { :blob => @blob }}
              format.json { JSON::dump(:blob => @blob.to_hash(self)) }
            end
          end
        end

        operation :destroy, :with_capability => :delete_blob do
          param :blob_id, :string, :required, 'The id of the blob to destroy'
          control do
            bucket_id = params[:id]
            blob_id = params[:blob_id]
            driver.delete_blob(credentials, bucket_id, blob_id)
            status 204
            respond_to do |format|
              format.xml
              format.json
              format.html { redirect(bucket_url(bucket_id)) }
            end
          end
        end

        action :stream, :http_method => :put, :with_capability => :create_blob do
          description "Stream new blob data into the blob"
          param :id, :string, :required
          param :blob_id, :string, :required
          control do
            if(env["BLOB_SUCCESS"]) #ie got a 200ok after putting blob
              content_type = env["CONTENT_TYPE"]
              content_type ||=  ""
              @blob = driver.blob(credentials, {:id => params[:blob],
                                                'bucket' => params[:bucket]})
              respond_to do |format|
                format.xml { haml :"blobs/show", :locals => { :blob => @blob } }
                format.html { haml :"blobs/show", :locals => { :blob => @blob } }
                format.json { JSON::dump(@blob.to_hash(self)) }
              end
            elsif(env["BLOB_FAIL"])
              report_error(500) #OK?
            else # small blobs - < 112kb dont hit the streaming monkey patch - use 'normal' create_blob
              # also, if running under webrick don't hit the streaming patch (Thin specific)
              bucket_id = params[:bucket]
              blob_id = params[:blob]
              temp_file = Tempfile.new("temp_blob_file")
              temp_file.write(env['rack.input'].read)
              temp_file.flush
              content_type = env['CONTENT_TYPE'] || ""
              blob_data = {:tempfile => temp_file, :type => content_type}
              user_meta = BlobHelper::extract_blob_metadata_hash(request.env)
              @blob = driver.create_blob(credentials, bucket_id, blob_id, blob_data, user_meta)
              temp_file.delete
              respond_to do |format|
                format.xml { haml :"blobs/show", :locals => { :blob => @blob } }
                format.html { haml :"blobs/show", :locals => { :blob => @blob } }
                format.json { JSON::dump(@blob.to_hash(self)) }
              end
            end
          end
        end

        action :metadata, :http_method => :head, :with_capability => :blob_metadata do
          param :id, :string, :required
          param :blob_id, :string, :required
          control do
            @blob_id = params[:blob_id]
            @blob_metadata = driver.blob_metadata(credentials, {:id => params[:blob_id], 'bucket' => params[:id]})
            if @blob_metadata
              @blob_metadata.each do |k,v|
                headers["X-Deltacloud-Blobmeta-#{k}"] = v
              end
              status 204
              respond_to do |format|
                format.xml
                format.json
              end
            else
              report_error(404)
            end
          end
        end

        action :update, :http_method => :post, :with_capability => :update_blob_metadata do
          param :blob_id, :string, :required
          control do
            meta_hash = BlobHelper::extract_blob_metadata_hash(request.env)
            success = driver.update_blob_metadata(credentials, {'bucket'=>params[:id], :id =>params[:blob_id], 'meta_hash' => meta_hash})
            if(success)
              meta_hash.each do |k,v|
                headers["X-Deltacloud-Blobmeta-#{k}"] = v
              end
              status 204
              respond_to do |format|
                format.xml
                format.json
              end
            else
              report_error(404) #FIXME is this the right error code?
            end
          end
        end

        action :content, :http_method => :get, :with_capability => :blob do
          description "Download blob content"
          param :id, :string, :required
          param :blob_id, :string, :required
          control do
            @blob = driver.blob(credentials, { :id => params[:blob_id], 'bucket' => params[:id]})
            if @blob
              params['content_length'] = @blob.content_length
              params['content_type'] = (@blob.content_type.nil? || @blob.content_type == "")? "application/octet-stream" : @blob.content_type
              params['content_disposition'] = "attachment; filename=#{@blob.id}"
              BlobStream.call(self, credentials, params)
            else
              report_error(404)
            end
          end
        end
      end


    end

  end
end
