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

load File.join(File.dirname(__FILE__), 'lib', 'initialize.rb')

def static_dir_for(name)
  Rack::Directory.new( File.join(File.dirname(__FILE__), "public", name))
end

# Mount static assets directories and index entrypoint
#
# The 'IndexApp' is small Sinatra::Base application that
# sits on the '/' route and display list of available frontends.
#
static_files = {
  '/' => Deltacloud::IndexApp,
  '/stylesheets' =>  static_dir_for('stylesheets'),
  '/javascripts' =>  static_dir_for('javascripts'),
  '/images' =>  static_dir_for('images')
}

# The 'generate_routes_for' also require the frontend
# servers and all dependencies.
#
routes = Deltacloud.generate_routes_for(frontends)

run Rack::Builder.new {
  use Rack::MatrixParams
  run Rack::URLMap.new(routes.merge(static_files))
}
