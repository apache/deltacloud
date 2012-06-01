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

# The default URL prefix (where to mount Deltacloud API)

# The default driver is 'mock'
ENV['API_DRIVER'] ||= 'mock'

load File.join(File.dirname(__FILE__), 'lib', 'deltacloud_rack.rb')

Deltacloud::configure do |server|
  server.root_url '/api'
  server.version '0.5.0'
  server.klass 'Deltacloud::API'
end

if ENV['API_FRONTEND'] == 'cimi'
  Deltacloud::configure do |server|
    server.root_url '/cimi'
    server.version '1.0.0'
    server.klass 'CIMI::API'
  end
end

if ENV['API_FRONTEND'] == 'ec2'
  Deltacloud::configure do |server|
    server.root_url '/'
    server.version '2012-04-01'
    server.klass 'Deltacloud::EC2::API'
  end
end

Deltacloud.require_frontend!

class IndexEntrypoint < Sinatra::Base
  get "/" do
    redirect Deltacloud[:root_url], 301
  end
end

run Rack::Builder.new {
  use Rack::MatrixParams
  use Rack::DriverSelect

  run Rack::URLMap.new(
    "/" => IndexEntrypoint.new,
    Deltacloud[:root_url] => Deltacloud[:klass],
    "/stylesheets" =>  Rack::Directory.new( "public/stylesheets" ),
    "/javascripts" =>  Rack::Directory.new( "public/javascripts" )
  )
} if respond_to? :run
