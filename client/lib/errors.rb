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

module DeltaCloud
  module HTTPError

    class ClientError < StandardError

      attr_reader :params, :driver, :provider

      def initialize(code, message, opts={}, backtrace=nil)
        @params, @driver, @provider = opts[:params], opts[:driver], opts[:provider]
        if code.to_s =~ /^5(\d{2})/
          message += "\nParameters: #{@params.inspect}\n"
          message += "Driver: #{@driver}@#{@provider}"
        end
        super("#{code}\n\n#{self.class.superclass}: #{message}\n\n")
        # If server provided us the backtrace, then replace client backtrace
        # with the server one.
        set_backtrace(backtrace) unless backtrace.nil?
      end
    end

    class ServerError < ClientError; end
    class UknownError < ClientError; end

    # For sake of consistent documentation we need to create
    # this exceptions manually, instead of using some meta-programming.
    # Client will really appreciate this it will try to catch some
    # specific exception.

    # Client errors (4xx)
    class BadRequest < ClientError; end
    class Unauthorized < ClientError; end
    class Forbidden < ClientError; end
    class NotFound < ClientError; end
    class MethodNotAllowed < ClientError; end
    class NotAcceptable < ClientError; end
    class RequestTimeout < ClientError; end
    class Gone < ClientError; end
    class ExpectationFailed < ClientError; end
    class UnsupportedMediaType < ClientError; end

    # Server errors (5xx)
    class DeltacloudError < ServerError; end
    class ProviderError < ServerError; end
    class ProviderTimeout < ServerError; end
    class ServiceUnavailable < ServerError; end
    class NotImplemented < ServerError; end

    class ExceptionHandler

      attr_reader :http_status_code, :message, :trace

      def initialize(status_code, message=nil, opts={}, backtrace=nil, &block)
        @http_status_code = status_code.to_i
        @trace = backtrace
        @message = message || client_error_messages[status_code] || 'No error message received'
        @options = opts
        instance_eval(&block) if block_given?
      end

      def on(code, exception_class)
        if code == @http_status_code
          raise exception_class.new(code, @message, @options, @trace)
        end
      end

      private

      def client_error_messages
        {
          400 => 'The request could not be understood by the server due to malformed syntax.',
          401 => 'Authentication required for this request or invalid credentials provided.',
          403 => 'Requested operation is not allowed for this resource.',
          404 => 'Not Found',
          405 => 'Method not allowed for this resource.',
          406 => 'Requested media type is not supported by server.',
          408 => 'The client did not produce a request within the time that the server was prepared to wait.',
          410 => 'The resource is no longer available'
        }
      end

    end

    def self.parse_response_error(response)
    
    end

    def self.client_error(code)
      ExceptionHandler.new(code) do
        # Client errors
        on 400, BadRequest
        on 401, Unauthorized
        on 403, Forbidden
        on 404, NotFound
        on 405, MethodNotAllowed
        on 406, NotAcceptable
        on 408, RequestTimeout
        on 410, Gone
      end
    end

    def self.server_error(code, message, opts={}, backtrace=nil)
      ExceptionHandler.new(code, message, opts, backtrace) do
        # Client errors
        on 400, BadRequest
        on 401, Unauthorized
        on 403, Forbidden
        on 404, NotFound
        on 405, MethodNotAllowed
        on 406, NotAcceptable
        on 408, RequestTimeout
        on 410, Gone
        on 415, UnsupportedMediaType
        on 417, ExpectationFailed
        # Server errors
        on 500, DeltacloudError
        on 501, NotImplemented
        on 502, ProviderError
        on 503, ServiceUnavailable
        on 504, ProviderTimeout
      end
      raise Deltacloud::HTTPError::UnknownError.new(code, message, opts, backtrace)
    end

  end
end
