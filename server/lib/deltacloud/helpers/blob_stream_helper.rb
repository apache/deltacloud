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

begin
  #--
  # based on the example from
  #   http://macournoyer.com/blog/2009/06/04/pusher-and-async-with-thin/
  #--
  class BlobStream
    AsyncResponse = [-1, {}, []].freeze
    def self.call(context, credentials, params)
     body = DeferrableBody.new
      #Get the headers out asap.
      EM.next_tick { context.env['async.callback'].call [200, {
        'Content-Type' => "#{params['content_type']}",
        'Content-Disposition' => params["content_disposition"],
        'Content-Length' => "#{params['content_length']}"}, body]
      }
      #call the driver from here. the driver method yields for every chunk
      #of blob it receives. Then use body.call to write that chunk as received.
      context.driver.blob_data(credentials, params[:id], params[:blob_id], params) {|chunk| body.call [chunk]} #close blob_data block
      body.succeed
      AsyncResponse.dup # Tell Thin to not close connection & work other requests
    end
  end

  class DeferrableBody
    include EventMachine::Deferrable

    def call(body)
      body.each do |chunk|
        @body_callback.call(chunk)
      end
    end

    def each(&blk)
      @body_callback = blk
    end

  end
rescue LoadError => e
  # EventMachine isn't available, disable blob streaming
  class BlobStream
    def self.call(env, credentials, params)
      raise NotImplementedError.new("Blob streaming is only supported under Thin")
    end
  end
end

module BlobHelper

  def self.extract_blob_metadata_hash(env_hash)
    meta_array = env_hash.select{|k,v| k.match(/^HTTP[-_]X[-_]Deltacloud[-_]Blobmeta[-_]/i)}
    metadata = meta_array.inject({}){ |result, array| result[array.first.upcase] = array.last; result}
    metadata
  end

DELTACLOUD_BLOBMETA_HEADER = /HTTP[-_]X[-_]Deltacloud[-_]Blobmeta[-_]/i

  #e.g. from HTTP-X-Deltacloud-Blobmeta-FOO:BAR to amz-meta-FOO:BAR
  def self.rename_metadata_headers(metadata, rename_to)
    metadata.gsub_keys(DELTACLOUD_BLOBMETA_HEADER, rename_to)
  end

  #in the following segment* methods, using context.env["QUERY_STRING"] rather than context.params so it works for both Thin and Sinatra request objects (streaming)
  def self.segmented_blob(request_context)
    return true if (request_context.env["HTTP_X_DELTACLOUD_BLOBTYPE"] == 'segmented' || request_context.env["QUERY_STRING"].match(/blob_type=segmented/))
    false
  end

  def self.segment_order(request_context)
    (request_context.env["HTTP_X_DELTACLOUD_SEGMENTORDER"] || request_context.env["QUERY_STRING"].match(/segment_order=(\w)*/){|m| m[0].split("=").pop})
  end

  def self.segmented_blob_id(request_context)
    (request_context.env["HTTP_X_DELTACLOUD_SEGMENTEDBLOB"] || request_context.env["QUERY_STRING"].match(/segmented_blob=(\w)*/){|m| m[0].split("=").pop})
  end

  def self.segmented_blob_op_type(request_context)
    is_segmented = segmented_blob(request_context)
    blob_id = segmented_blob_id(request_context)
    segment_order = segment_order(request_context)
    #if blob_type=segmented AND segmented_blob_id AND segment_order then it is a "SEGMENT"
    #if blob_type=segmented AND segmented_blob_id then it is a "FINALIZE"
    #if blob_type=segmented then it is "INIT"
    return "segment" if (is_segmented && blob_id && segment_order)
    return "finalize" if (is_segmented && blob_id)
    return "init" if is_segmented
    nil # should explode something instead
  end

  #in "1=abc , 2=def , 3=ghi"
  #out {"1"=>"abc", "2"=>"def", "3"=>"ghi"}
  def self.extract_segmented_blob_manifest(request)
    manifest_hash = request.body.read.split(",").inject({}) do |res,current|
      k,v=current.strip.split("=")
      res[k]=v
      res
    end
  end

end

#Monkey patch for streaming blobs:
# Normally a client will upload a blob to deltacloud and thin will put
# this into a tempfile. Then deltacloud would stream up to the provider:
#   i.e.  client =-->>TEMP_FILE-->> deltacloud =-->>STREAM-->> provider
# Instead we want to recognise that this is a 'PUT blob' operation and
# start streaming to the provider as the request is received:
#   i.e.  client =-->>STREAM-->> deltacloud =-->>STREAM-->> provider
module Thin
  class Request

    alias_method :move_body_to_tempfile_orig, :move_body_to_tempfile if defined?(Thin::Response)
    private
      def move_body_to_tempfile
        if BlobStreamIO::is_put_blob(self)
          @body = BlobStreamIO.new(self)
        else
          move_body_to_tempfile_orig
        end
      end

  end
end

#monkey patch for Net:HTTP
module Net
  class HTTP

    alias :request_orig :request

    def request(req, body = nil, blob_stream = nil, &block)
      unless blob_stream
        return request_orig(req, body, &block)
      end
      @blob_req = req
      do_start #start the connection

      req.set_body_internal body
      begin_transport req
      req.write_header_m @socket,@curr_http_version, edit_path(req.path)
      @socket
    end

    class Put < HTTPRequest
      def write_header_m(sock, ver, path)
        write_header(sock, ver, path)
      end
    end

    def end_request
      begin
        res = HTTPResponse.read_new(@socket)
      end while res.kind_of?(HTTPContinue)
      res.reading_body(@socket, @blob_req.response_body_permitted?) {
                                          yield res if block_given? }
      end_transport @blob_req, res
      do_finish
      res
    end
  end

end

class BlobStreamIO

  attr_accessor :size, :provider, :sock
  def initialize(request)
    @client_request = request
    @size = 0
    bucket, blob = parse_bucket_blob(request.env["PATH_INFO"])
    user, password = parse_credentials(request.env['HTTP_AUTHORIZATION'])
    content_type = request.env['CONTENT_TYPE'] || ""
    #deal with blob_metadata: (X-Deltacloud-Blobmeta-name: value)
    user_meta = BlobHelper::extract_blob_metadata_hash(request.env)
    @content_length = request.env['CONTENT_LENGTH']
    @http, provider_request = Deltacloud::API.driver.blob_stream_connection({:user=>user,
       :password=>password, :bucket=>bucket, :blob=>blob, :metadata=> user_meta,
       :content_type=>content_type, :content_length=>@content_length, :context=>request })
    @content_length = @content_length.to_i #for comparison of size in '<< (data)'
    @sock = @http.request(provider_request, nil, true)
  end
  def << (data)
    @sock.write(data)
    @size += data.length
    if (@size >= @content_length)
      result = @http.end_request
      if result.is_a?(Net::HTTPSuccess)
        @client_request.env["BLOB_SUCCESS"] = "true"
        if BlobHelper.segmented_blob_op_type(@client_request) == "segment"
          @client_request.env["BLOB_SEGMENT_ID"] = Deltacloud::API.driver.blob_segment_id(@client_request, result)
        end
      else
        @client_request.env["BLOB_FAIL"] = result.body
      end
    end
  end

  def rewind
  end

  #use the Request.env hash (populated by the ThinParser) to determine whether
  #this is a post blob operation. By definition, only get here with a body of
  # > 112kbytes - thin/lib/thin/request.rb:12 MAX_BODY = 1024 * (80 + 32)
  def self.is_put_blob(request = nil)
    path = request.env['PATH_INFO']
    method = request.env['REQUEST_METHOD']
    if ( path =~ /^#{Regexp.escape(Deltacloud::API.settings.root_url)}\/buckets/ && method == 'PUT' )
      return true
    else
      return false
    end
  end

  private

  def parse_bucket_blob(request_string)
    array = request_string.gsub(/(&\w*=\w*)*$/, "").split("/")
    blob = array.pop
    bucket = array.pop
    return bucket, blob
  end

  def parse_credentials(request_string)
    decoded = Base64.decode64(request_string.split('Basic ').last)
    key = decoded.split(':').first
    pass = decoded.split(':').last
    return key, pass
  end

end
