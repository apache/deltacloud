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
ENV['API_FRONTEND'] ||= 'deltacloud'

load File.join(File.dirname(__FILE__), 'lib', 'deltacloud_rack.rb')

Deltacloud::configure do |server|
  server.root_url '/api'
  server.version '0.5.0'
  server.klass 'Deltacloud::API'
end

Deltacloud::configure(:cimi) do |server|
  server.root_url '/cimi'
  server.version '1.0.0'
  server.klass 'CIMI::API'
end

Deltacloud::configure(:ec2) do |server|
  server.root_url '/'
  server.version '2012-04-01'
  server.klass 'Deltacloud::EC2::API'
end

routes = {}

# If user wants to launch multiple frontends withing a single instance of DC API
# then require them and prepare the routes for Rack
#
# NOTE: The '/' will not be generated, since multiple frontends could have
#       different root_url's
#
if ENV['API_FRONTEND'].split(',').size > 1

  ENV['API_FRONTEND'].split(',').each do |frontend|
    Deltacloud.require_frontend!(frontend)
    routes.merge!({
      Deltacloud[frontend].root_url => Deltacloud[frontend].klass
    })
  end

else
  Deltacloud.require_frontend!(ENV['API_FRONTEND'])
  class IndexEntrypoint < Sinatra::Base
    get "/" do
      redirect Deltacloud[ENV['API_FRONTEND']].root_url, 301
    end
  end
  routes['/'] = IndexEntrypoint.new
  routes[Deltacloud[ENV['API_FRONTEND']].root_url] = Deltacloud[ENV['API_FRONTEND']].klass
end


run Rack::Builder.new {
  use Rack::MatrixParams
  use Rack::DriverSelect

  routes.merge!({
    "/stylesheets" =>  Rack::Directory.new( "public/stylesheets" ),
    "/javascripts" =>  Rack::Directory.new( "public/javascripts" )
  })

  run Rack::URLMap.new(routes)

} if respond_to? :run
