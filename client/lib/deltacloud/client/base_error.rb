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

module Deltacloud::Client

  # Reporting internal client errors
  #
  class Error < StandardError; end

  class BaseError < Error
    attr_reader :server_backtrace
    attr_reader :driver
    attr_reader :provider
    attr_reader :status
    attr_reader :original_error

    def initialize(opts={})
      if opts.is_a? Hash
        @server_backtrace = opts[:server_backtrace]
        @driver = opts[:driver]
        @provider = opts[:provider]
        @status = opts[:status]
        @original_error = opts[:original_error]
        super(opts[:message])
      else
        super(opts)
      end
    end

    # If the Deltacloud API server error response contain backtrace from
    # server,then make this backtrace available as part of this exception
    # backtrace
    #
    def set_backtrace(backtrace)
      return super(backtrace) if @server_backtrace.nil?
      super([
        backtrace[0..3],
        "-------Deltacloud API backtrace-------",
        @server_backtrace.split[0..10],
      ].flatten)
    end

  end

  # Report 401 errors
  class AuthenticationError < BaseError; end

  # Report 502 errors (back-end cloud provider encounter error)
  class BackendError < BaseError; end

  # Report 5xx errors (error on Deltacloud API server)
  class ServerError < BaseError; end

  # Report 501 errors (collection or operation is not supported)
  class NotSupported < ServerError; end

  # Report 4xx failures (client failures)
  class ClientFailure < BaseError; end

  # Report 404 error (object not found)
  class NotFound < BaseError; end

  # Report 405 failures (resource state does not permit the requested operation)
  class InvalidState < ClientFailure; end

  # Report this when client do Image#launch using incompatible HWP
  class IncompatibleHardwareProfile < ClientFailure; end
end
