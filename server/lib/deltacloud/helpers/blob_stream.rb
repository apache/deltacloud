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

include Deltacloud
begin
  require 'eventmachine'
  #--
  # based on the example from http://macournoyer.com/blog/2009/06/04/pusher-and-async-with-thin/
  #--
  class BlobStream
    AsyncResponse = [-1, {}, []].freeze
    def self.call(env, credentials, params)
      body = DeferrableBody.new
      #Get the headers out asap. Don't specify a content-type let
      #the client guess and if they can't they SHOULD default to
      #'application/octet-stream' anyway as per:
      #http://www.w3.org/Protocols/rfc2616/rfc2616-sec7.html#sec7.2.1
      EM.next_tick { env['async.callback'].call [200, {
        'Content-Type' => "#{params['content_type']}",
        'Content-Disposition' => params["content_disposition"],
        'Content-Length' => "#{params['content_length']}"}, body]
      }
      #call the driver from here. the driver method yields for every chunk of blob it receives. We then
      #use body.call to write that chunk as received.
      driver.blob_data(credentials, params[:bucket], params[:blob], params) {|chunk| body.call ["#{chunk}"]} #close blob_data block
      body.succeed
      AsyncResponse # Tells Thin to not close the connection and continue it's work on other request
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

class Hash

  def gsub_keys(pattern, replacement)
    rgx_pattern = Regexp.compile(pattern, true)
    remove = []
    self.each_key do |key|
      if key.to_s.match(rgx_pattern)
         new_key = key.to_s.gsub(rgx_pattern, replacement).downcase
         self[new_key] = self[key]
         remove << key
      end
    end
    #remove the original keys
    self.delete_if{|k,v| remove.include?(k)}
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

require 'net/http'
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

require 'base64'
class BlobStreamIO

  attr_accessor :size, :provider, :sock

  def initialize(request)
    @client_request = request
    @size = 0
    bucket, blob = parse_bucket_blob(request.env["PATH_INFO"])
    user, password = parse_credentials(request.env['HTTP_AUTHORIZATION'])
    content_type = request.env['CONTENT_TYPE'] || ""
    #deal with blob_metadata: (X-Deltacloud-Blobmeta-name: value)
    meta_array = request.env.select{|k,v| k.match(/^HTTP[-_]X[-_]Deltacloud[-_]Blobmeta[-_]/i)}
    user_meta = meta_array.inject({}){ |result, array| result[array.first.upcase] = array.last; result}
    @content_length = request.env['CONTENT_LENGTH']
    @http, provider_request = driver.blob_stream_connection({:user=>user,
       :password=>password, :bucket=>bucket, :blob=>blob, :metadata=> user_meta,
       :content_type=>content_type, :content_length=>@content_length })
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
    if ( path =~ /^#{Regexp.escape(Sinatra::UrlForHelper::DEFAULT_URI_PREFIX)}\/buckets/ && method == 'PUT' )
      return true
    else
      return false
    end
  end

  private

  def parse_bucket_blob(request_string)
    array = request_string.split("/")
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
