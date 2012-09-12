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
  class Base < Sinatra::Base

    include Sinatra::Rabbit
    include Sinatra::Rabbit::Features

    helpers Deltacloud::Helpers::Drivers
    helpers Sinatra::AuthHelper
    helpers Deltacloud::Helpers::Application
    helpers Sinatra::Rabbit::URLHelper
    register Rack::RespondTo

    enable :xhtml
    enable :dump_errors
    enable :show_errors
    enable :method_override
    disable :show_exceptions

    set :config, Deltacloud[:deltacloud]
    set :root_url, config.root_url
    set :root_path, config.root_url
    set :version, config.version
    set :root, File.join(File.dirname(__FILE__), '..', '..', '..')
    set :views, File.join(settings.root, 'views')
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
      headers 'X-Deltacloud-Driver' => driver_name
      if provider_name
        headers 'X-Deltacloud-Provider' => provider_name
      end
    end

  end
end
