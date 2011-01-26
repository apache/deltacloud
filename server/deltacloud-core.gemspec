#
# Copyright (C) 2009  Red Hat, Inc.
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
  s.author = 'Red Hat, Inc.'
  s.homepage = "http://www.deltacloud.org"
  s.email = 'deltacloud-users@lists.fedorahosted.org'
  s.name = 'deltacloud-core'

  s.description = <<-EOF
    The Deltacloud API is built as a service-based REST API.
    You do not directly link a Deltacloud library into your program to use it.
    Instead, a client speaks the Deltacloud API over HTTP to a server
    which implements the REST interface.
  EOF

  s.version = '0.2.0'
  s.date = Time.now
  s.summary = %q{Deltacloud REST API}
  s.files = FileList[
    'Rakefile',
    'config.ru',
    '*.rb',
    'log',
    'tmp',
    'support/fedora/**',
    'lib/**/*.rb',
    'lib/**/*.yml',
    'views/**/*.haml',
    'views/instance_states/*.erb',
    'public/favicon.ico',
    'public/images/*.png',
    'public/javascripts/*.js',
    'public/stylesheets/compiled/*.css',
    'bin/deltacloudd'
  ].to_a

  s.bindir = 'bin'
  s.executables = 'deltacloudd'
  s.test_files= Dir.glob("tests/*_test.rb")
  s.extra_rdoc_files = Dir["COPYING"]
  s.required_ruby_version = '>= 1.8.1'

  s.add_dependency('rake', '>= 0.8.7')
  s.add_dependency('haml', '>= 2.2.17')
  s.add_dependency('sinatra', '>= 0.9.4')
  s.add_dependency('rack', '>= 1.0.0', '<=1.1.0')
  s.add_dependency('rack-accept', '~> 0.4.3')
  s.add_dependency('json', '>= 1.1.9')
  s.add_development_dependency('compass', '>= 0.8.17')
  s.add_development_dependency('nokogiri', '>= 1.4.1', '< 1.4.4')
  s.add_development_dependency('rack-test', '>= 0.5.3')
  s.add_development_dependency('cucumber', '>= 0.6.3')
  s.add_development_dependency('rcov', '>= 0.9.8')

end
