# Copyright (C) 2010  Red Hat, Inc.
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
    EM.next_tick { env['async.callback'].call [200, {'Content-Type' => "#{params['content_type']}", 'Content-Length' => "#{params['content_length']}"}, body] }
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
