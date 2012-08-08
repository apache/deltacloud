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
  server.version '1.0.0'
  server.klass 'Deltacloud::API'
  server.logger Rack::DeltacloudLogger.setup(ENV['API_LOG'], ENV['API_VERBOSE'])
  server.default_driver ENV['API_DRIVER']
end

Deltacloud::configure(:cimi) do |server|
  server.root_url '/cimi'
  server.version '1.0.0'
  server.klass 'CIMI::API'
  server.logger Rack::DeltacloudLogger.setup(ENV['API_LOG'], ENV['API_VERBOSE'])
  server.default_driver ENV['API_DRIVER']
end

Deltacloud::configure(:ec2) do |server|
  server.root_url '/'
  server.version '2012-04-01'
  server.klass 'Deltacloud::EC2::API'
  server.logger Rack::DeltacloudLogger.setup(ENV['API_LOG'], ENV['API_VERBOSE'])
  server.default_driver ENV['API_DRIVER']
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
    Deltacloud[frontend.to_sym].require!
    routes.merge!({
      Deltacloud[frontend].root_url => Deltacloud[frontend].klass
    })
  end

else
  Deltacloud[ENV['API_FRONTEND'].to_sym].require!
  Deltacloud[ENV['API_FRONTEND'].to_sym].default_frontend!
  class IndexEntrypoint < Sinatra::Base
    get "/" do
      redirect Deltacloud.default_frontend.root_url, 301
    end
  end
  routes['/'] = IndexEntrypoint.new
  routes[Deltacloud.default_frontend.root_url] = Deltacloud.default_frontend.klass
end


run Rack::Builder.new {
  use Rack::MatrixParams
  use Rack::DriverSelect

  routes.merge!({
    "/stylesheets" =>  Rack::Directory.new( File.join(File.dirname(__FILE__), "public", "stylesheets") ),
    "/javascripts" =>  Rack::Directory.new( File.join(File.dirname(__FILE__), "public", "javascripts") )
  })

  run Rack::URLMap.new(routes)

} if respond_to? :run
