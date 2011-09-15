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

require 'sinatra/base'

module Sinatra
  module VerboseLogger

    module Helpers

      def info(message)
        puts sprintf("\033[1;34m[INFO: #{caller_method_name}]\033[0m: %s", message.inspect)
      end

      alias :debug :info

      def warn(message)
        puts sprintf("\033[1;31m[WARN: #{caller_method_name}]\033[0m: %s", message.inspect)
      end

      private

      def caller_method_name
        caller(2).first
      end

    end

    def enable_verbose_logging!
      disable :logging
      before {
        puts sprintf("\n\033[1;29mProcessing %s\033[0m (for %s at #{Time.now}) [%s] [\033[1;29m%s\033[0m]",
                     request.path_info, request.ip, request.request_method, driver_name)
        puts "Parameters: #{params.inspect}"
        if provider=Thread::current[:provider] || ENV['API_PROVIDER']
          puts "Provider: #{provider}"
        end
        puts "Authentication: #{request.env['HTTP_AUTHORIZATION'].split(' ').first}" if request.env['HTTP_AUTHORIZATION']
        puts "Server: #{request.env['SERVER_SOFTWARE']}"
        puts "Accept: #{request.env['HTTP_ACCEPT']}"
        puts
      }
      after {
        puts sprintf("\nCompleted in \033[1;29m%4f\033[0m | %4f | %s | \033[1;36m%s\033[0m | %s\n",
                     response.header['X-Backend-Runtime'] || 0, response.header['X-Runtime'] || 0, response.status, response.content_type, request.url)
      }
    end

    def self.registered(app)
      app.helpers VerboseLogger::Helpers
      app.enable_verbose_logging! if ENV['API_VERBOSE']
    end
  end
end

Sinatra::Application.register Sinatra::VerboseLogger

Deltacloud::BaseDriver.class_eval do
  include Sinatra::VerboseLogger::Helpers
end
