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

require_relative '../sinatra'
require_relative './helpers'
require_relative './query_parser'

module Deltacloud::EC2
  class API < Sinatra::Base

    extend Deltacloud::Helpers::Drivers

    use Rack::ETag
    use Deltacloud[:ec2].logger unless RUBY_PLATFORM == 'java'

    helpers Sinatra::AuthHelper
    helpers Deltacloud::Helpers::Drivers
    helpers Deltacloud::EC2::Errors

    enable :xhtml
    enable :dump_errors
    enable :show_errors
    enable :logging
    disable :show_exceptions

    set :config, Deltacloud[:ec2]
    set :root_url, config.root_url
    set :root_path, config.root_url
    set :version, config.version
    set :root, File.join(File.dirname(__FILE__), '..', '..')
    set :public_folder, root + '/public'
    set :views, File.join(File.dirname(__FILE__), 'views')

    error Deltacloud::EC2::QueryParser::InvalidAction do
      status 400
      haml :error, :locals => { :code => 'InvalidAction', :message => 'The requested action is not valid for this web service' }
    end

    after do
      headers 'Server' => 'Apache-Deltacloud-EC2/' + settings.version
    end

    error Deltacloud::Exceptions::AuthenticationFailure do
      status 401
    end

    get '/' do
      headers 'Connection' => 'close'
      unless params['Action']
        redirect settings.root_url, 301
        halt
      end
      ec2_action = QueryParser.parse(params, request_id)
      ec2_action.perform!(credentials, driver)
      ec2_action.to_xml(self)
    end

  end
end
