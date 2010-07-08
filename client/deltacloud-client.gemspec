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


Gem::Specification.new do |s|
  s.author = 'Red Hat, Inc.'
  s.homepage = "http://www.deltacloud.org"
  s.email = 'deltacloud-users@lists.fedorahosted.org'
  s.name = 'deltacloud-client'
  s.description = %q{Deltacloud REST Client for API}
  s.version = '0.0.3'
  s.summary = %q{Deltacloud REST Client}
  s.files = Dir['Rakefile', 'credentials.yml', 'lib/**/*.rb', 'init.rb', 'bin/deltacloudc']
  s.bindir = 'bin'
  s.executables = 'deltacloudc'
  s.default_executable = 'deltacloudc'
  s.test_files= Dir.glob("specs/**/**")
  s.extra_rdoc_files = Dir["COPYING"]

  s.add_dependency('rest-client', '>= 1.3.1')
end
