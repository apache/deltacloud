#
# Copyright (C) 2009  Red Hat, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require 'rake'

@spec=Gem::Specification.new do |s|
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

  s.version = '0.0.1'
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
  s.add_dependency('eventmachine', '>= 0.12.10')
  s.add_dependency('haml', '>= 2.2.17')
  s.add_dependency('sinatra', '>= 0.9.4')
  s.add_dependency('rack', '>= 1.0.0')
  s.add_dependency('thin', '>= 1.2.5')
  s.add_dependency('rerun', '>= 0.5.2')
  s.add_dependency('json', '>= 1.2.3')
  s.add_development_dependency('compass', '>= 0.8.17')
  s.add_development_dependency('nokogiri', '>= 1.4.1')
  s.add_development_dependency('rack-test', '>= 0.5.3')
  s.add_development_dependency('cucumber', '>= 0.6.3')
  s.add_development_dependency('rcov', '>= 0.9.8')

end
