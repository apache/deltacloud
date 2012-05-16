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

require_relative './helpers'
require_relative './collections'

CMWG_NAMESPACE = "http://www.dmtf.org/cimi"

module CIMI
  class API < Collections::Base

    # Enable logging
    use Rack::CommonLogger
    use Rack::Date
    use Rack::ETag
    use Rack::MatrixParams
    use Rack::DriverSelect
    use Rack::Accept
    use Rack::MediaType

    helpers CIMIHelper

    include Deltacloud::Helpers
    include CIMI::Collections
    include CIMI::Model

    get Deltacloud[:root_url] do
      redirect Deltacloud[:root_url] + '/cloudEntryPoint', 301
    end

  end
end
