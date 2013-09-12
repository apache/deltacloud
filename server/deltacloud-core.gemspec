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

require File::expand_path(File::join(File::dirname(__FILE__), './lib/deltacloud/version.rb'))

Gem::Specification.new do |s|
  s.author = 'The Apache Software Foundation'
  s.homepage = "http://www.deltacloud.org"
  s.email = 'dev@deltacloud.apache.org'
  s.name = 'deltacloud-core'

  s.description = <<-EOF
    The Deltacloud API is built as a service-based REST API.
    You do not directly link a Deltacloud library into your program to use it.
    Instead, a client speaks the Deltacloud API over HTTP to a server
    which implements the REST interface.
  EOF

  s.version = Deltacloud::API_VERSION
  s.date = Time.now
  s.summary = %q{Deltacloud REST API}
  s.files = [
    'Rakefile',
    '*.gemspec',
    'config.ru',
    '*.rb',
    'log',
    'config/drivers/*.yaml',
    'config/*.yaml',
    'config/*.xml',
    'tmp',
    'support/fedora/**',
    'support/condor/bash/**',
    'support/condor/config/**',
    'lib/*.rb',
    'lib/**/*.rb',
    'lib/**/*.yml',
    'lib/**/*.haml',
    'db/**/*.rb',
    'tests/**/*.rb',
    'views/**/*.haml',
    'views/instance_states/*.erb',
    'public/favicon.ico',
    'public/images/*.png',
    'public/javascripts/*.js',
    'public/stylesheets/*.css',
    'public/stylesheets/images/*.png',
    'public/stylesheets/compiled/*.css',
    'bin/deltacloudd'
  ].map { |f| Dir[f] }.flatten

  s.bindir = 'bin'
  s.executables = ['deltacloudd', 'deltacloud-db-upgrade']
  s.test_files= Dir.glob("tests/**/*_test.rb")
  s.extra_rdoc_files = Dir["LICENSE", "DISCLAIMER", "NOTICE"]
  s.required_ruby_version = '>= 1.8.6'
  s.has_rdoc = 'false'
  s.add_dependency('rake', '>= 0.8.7')
  s.add_dependency('haml', '>= 2.2.17')
  s.add_dependency('sinatra-rabbit', '>= 1.1.6')
  s.add_dependency('rack', '>= 1.0.0')
  s.add_dependency('rack-accept')
  s.add_dependency('json_pure', '>= 1.5.0')
  s.add_dependency('net-ssh', '>= 2.0.0')
  s.add_dependency('nokogiri', '>= 1.4.3')
  s.add_dependency('require_relative') if RUBY_VERSION < '1.9'

  s.add_dependency('sequel')
  s.add_dependency('tilt')
  s.add_dependency('sinatra')


  if RUBY_PLATFORM == 'java'
    s.add_dependency('jdbc-sqlite3')
    s.add_dependency('jruby-openssl')
    s.add_dependency('puma')
  else
    s.add_dependency('sqlite3')
    s.add_dependency('thin', '>= 1.2.5')
  end

  # dependencies for various cloud providers:

  # RHEV-M and oVirt
  s.add_dependency('rbovirt', '>=0.0.19')

  # Amazon EC2 S3
  s.add_dependency('aws', '>=2.7.0')
  # Microsoft Azure
  s.add_dependency('waz-storage', '>=1.1.0')

  # Rackspace Cloudservers Cloudfiles
  s.add_dependency('cloudservers')
  s.add_dependency('cloudfiles')

  # Terremark Vcloud Express
  s.add_dependency('fog', '>= 1.4.0')

  # Rhevm and Condor Cloud
  s.add_dependency('rest-client')

  # Condor Cloud
  s.add_dependency('uuidtools', '>= 2.1.1')

  # Openstack Compute and Object-Storage
  s.add_dependency('openstack', '>= 1.0.9')

  # Aruba Cloud
  s.add_dependency('savon', '>= 1.0.0')

  # VSphere
  s.add_dependency('rbvmomi')

  # Profitbricks
  s.add_dependency('profitbricks')

end
