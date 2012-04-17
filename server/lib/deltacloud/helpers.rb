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

require_relative 'helpers/driver_helper'
require_relative 'helpers/auth_helper'
require_relative 'helpers/url_helper'
require_relative 'helpers/deltacloud_helper'
require_relative 'helpers/rabbit_helper'
require_relative 'helpers/blob_stream_helper'
require_relative 'core_ext/string'
require_relative 'core_ext/array'
require_relative 'core_ext/hash'
require_relative 'core_ext/integer'
require_relative 'core_ext/proc'

module Deltacloud::Collections
  class Base < Sinatra::Base

    extend Deltacloud::Helpers::Drivers
    include Sinatra::Rabbit::Features

    helpers Deltacloud::Helpers::Drivers
    helpers Sinatra::AuthHelper
    helpers Sinatra::UrlForHelper
    helpers Rack::RespondTo::Helpers
    helpers Deltacloud::Helpers::Application

    register Rack::RespondTo

    enable :xhtml
    enable :dump_errors
    enable :show_errors
    enable :method_override
    disable :show_exceptions

    set :root_url, API_ROOT_URL
    set :version, API_VERSION
    set :root, File.join(File.dirname(__FILE__), '..', '..')
    set :views, root + '/views'
    set :public_folder, root + '/public'

    error do
      report_error
    end

    error Deltacloud::ExceptionHandler::ValidationFailure do
      report_error
    end

    before do
      # Respond with 400, If we don't get a http Host header,
      halt 400, "Unable to find HTTP Host header" if @env['HTTP_HOST'] == nil
    end

    after do
      headers 'Server' => 'Apache-Deltacloud/' + settings.version
    end

    def self.new_route_for(route, &block)
      get route_for('/' + route.to_s + '/new') do
        instance_eval(&block) if block_given?
        respond_to do |format|
          format.html do
            haml :"#{route}/new"
          end
        end
      end
    end

    def self.check_capability(opts={})
      Sinatra::Rabbit.set :check_capability, opts[:for]
    end

    def self.check_features(opts={})
      Sinatra::Rabbit.set :check_features, opts[:for]
    end

    def self.route_for(url)
      "#{settings.root_url}#{url}"
    end

  end
end
