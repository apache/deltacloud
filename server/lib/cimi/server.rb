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
require_relative './collections'

CMWG_NAMESPACE = "http://schemas.dmtf.org/cimi/1"

module CIMI
  class API < Collections::Base

    # Enable logging
    use Deltacloud[:cimi].logger
    use Rack::Date
    use Rack::ETag
    use Rack::MatrixParams
    use Rack::DriverSelect

    helpers CIMI::Helper

    include Deltacloud::Helpers
    include CIMI::Collections
    include CIMI::Model

    enable :method_override
    disable :show_exceptions
    disable :dump_errors
    set :haml, :format => :xhtml

    helpers Sinatra::Rabbit::URLFor(CIMI.collections)

  end
end
