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

module Deltacloud
  class ErrorResponse < Faraday::Response::Middleware

    include Deltacloud::Client::Helpers::Model

    # This method tries to parse the error XML from Deltacloud API
    # In case there is no error returned in body, it will try to use
    # the generic error reporting.
    #
    # - name    -> Deltacloud::Client::+Class+
    # - error   -> Deltacloud XML error representation
    # - message -> Exception message (overiden by error body message if
    #              present)
    #
    def client_error(name, error, message=nil)
      args = {
        :message => message,
        :status => error ? error[:status] : '500'
      }
      # If Deltacloud API sends an error in the response body, parse it.
      # Otherwise, when DC API sends just plain text error, use
      # it as the exception message.
      # If DC API does not send anything back, then fallback to
      # the 'message' attribute.
      #
      if error and !error[:body].empty?
        if xml_error?(error)
          args.merge! parse_error(error[:body].to_xml.root)
        else
          args[:message] = error[:body]
        end
      end
      error(name).new(args)
    end

    def call(env)
      @app.call(env).on_complete do |e|
        case e[:status].to_s
        when '401'
          raise client_error(:authentication_error, e,
            'Invalid :api_user or :api_password')
        when '405'
          raise client_error(
            :invalid_state, e, 'Resource state does not permit this action'
          )
        when '404'
          raise client_error(:not_found, e, 'Object not found')
        when /40\d/
          raise client_error(:client_failure, e)
        when '500'
          raise client_error(:server_error, e)
        when '502'
          raise client_error(:backend_error, e)
        when '501'
          raise client_error(:not_supported, e)
        end
      end
    end

    private

    def xml_error?(error)
      error[:body].to_xml.root && error[:body].to_xml.root.name == 'error'
    end

    # Parse the Deltacloud API error body to Hash
    #
    def parse_error(body)
      args = {}
      args[:original_error] = body.to_s
      args[:server_backtrace] = body.text_at('backtrace')
      args[:message] ||= body.text_at('message')
      args[:driver] = body.attr_at('backend', 'driver')
      args[:provider] = body.attr_at('backend', 'provider')
      args
    end
  end
end
