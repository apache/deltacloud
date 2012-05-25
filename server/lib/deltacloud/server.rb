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

require 'rubygems'
require 'crack'
require 'json'
require 'yaml'
require 'haml'
require 'sinatra/base'
require 'sinatra/rabbit'

require_relative '../sinatra'
require_relative './models'
require_relative './drivers'
require_relative './helpers'
require_relative './collections'

module Deltacloud
  class API < Collections::Base

    # Enable logging
    use Rack::CommonLogger
    use Rack::Date
    use Rack::ETag
    use Rack::MatrixParams
    use Rack::DriverSelect
    use Rack::Accept
    use Rack::MediaType

    include Deltacloud::Helpers
    include Deltacloud::Collections

    get Deltacloud[:root_url] + '/?' do
      if params[:force_auth]
        return [401, 'Authentication failed'] unless driver.valid_credentials?(credentials)
      end
      respond_to do |format|
        format.xml { haml :"api/show" }
        format.json { xml_to_json :"api/show" }
        format.html { haml :"api/show" }
      end
    end

    post Deltacloud[:root_url] + '/?' do
      param_driver, param_provider = params["driver"], params["provider"]
      if param_driver
        redirect "#{Deltacloud[:root_url]}\;driver=#{param_driver}", 301
      elsif param_provider && param_provider != "default"
#FIXME NEEDS A BETTER WAY OF GRABBING CURRENT DRIVER FROM MATRIX PARAMS...
        current_matrix_driver = env["HTTP_REFERER"].match(/\;(driver)=(\w*).*$/i)
        if current_matrix_driver
          redirect "#{Deltacloud[:root_url]}\;driver=#{$2}\;provider=#{param_provider}", 301
        else
          redirect "#{Deltacloud[:root_url]}\;provider=#{param_provider}", 301
        end
      else
        redirect "#{Deltacloud[:root_url]}", 301
      end
    end

  end
end

