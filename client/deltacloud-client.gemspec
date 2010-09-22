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


Gem::Specification.new do |s|
  s.author = 'Red Hat, Inc.'
  s.homepage = "http://www.deltacloud.org"
  s.email = 'deltacloud-users@lists.fedorahosted.org'
  s.name = 'deltacloud-client'
  s.description = %q{Deltacloud REST Client for API}
  s.version = '0.0.9.6'
  s.summary = %q{Deltacloud REST Client}
  s.files = Dir['Rakefile', 'lib/**/*.rb', 'init.rb', 'bin/deltacloudc']
  s.bindir = 'bin'
  s.executables = 'deltacloudc'
  s.default_executable = 'deltacloudc'
  s.test_files= Dir.glob("specs/**/**")
  s.extra_rdoc_files = Dir["COPYING"]

  # Rakefile needs to create spec for both platforms (ruby and java), using the
  # $platform global variable. In all other cases, we figure it out from
  # RUBY_PLATFORM.
  s.platform = $platform || RUBY_PLATFORM[/java/] || 'ruby'

  s.add_dependency('rest-client', '>= 1.4.2')
  s.add_dependency('nokogiri', '>= 1.4.1') if s.platform.to_s == 'ruby'
  s.add_dependency('nokogiri', '>= 1.5.0.beta.2') if s.platform.to_s == 'java'
  s.add_development_dependency('rspec', '>= 1.3.0')
end
