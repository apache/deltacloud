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

require 'rake'

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

  s.version = '1.0.0'
  s.date = Time.now
  s.summary = %q{Deltacloud REST API}
  s.files = FileList[
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
    'lib/**/*.rb',
    'lib/**/*.yml',
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
  ].to_a

  s.bindir = 'bin'
  s.executables = 'deltacloudd'
  s.test_files= Dir.glob("tests/*_test.rb")
  s.extra_rdoc_files = Dir["LICENSE", "DISCLAIMER", "NOTICE"]
  s.required_ruby_version = '>= 1.8.1'
  s.has_rdoc = 'false'
  s.add_dependency('rake', '>= 0.8.7')
  s.add_dependency('haml', '>= 2.2.17')
  s.add_dependency('sinatra', '>= 0.9.4')
  s.add_dependency('sinatra-rabbit', '>= 1.0.10')
  s.add_dependency('crack')
  s.add_dependency('rack', '>= 1.0.0')
  s.add_dependency('rack-accept')
  s.add_dependency('json', '>= 1.1.9')
  s.add_dependency('net-ssh', '>= 2.0.0')
  s.add_dependency('thin', '>= 1.2.5')
  s.add_dependency('nokogiri', '>= 1.4.3')
  s.add_dependency('require_relative')

# dependencies for various cloud providers:
# RHEV-M
  s.add_dependency('rbovirt', '>=0.0.6')

# Amazon EC2 S3
  s.add_dependency('aws', '>=2.5.4')
# Microsoft Azure
  s.add_dependency('waz-storage', '>=1.1.0')

# Rackspace Cloudservers Cloudfiles
  s.add_dependency('cloudservers')
  s.add_dependency('cloudfiles')

# Terremark Vcloud Express
  s.add_dependency('fog', '>= 1.4.0')
  s.add_dependency('excon', '>= 0.14.2' )

# Rhevm and Condor Cloud
  s.add_dependency('rest-client')

# Condor Cloud
  s.add_dependency('uuidtools', '>= 2.1.1')

# Openstack Compute and Object-Storage
  s.add_dependency('openstack', '>= 1.0.1')

end
