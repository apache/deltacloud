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

require 'rubygems'
require 'yaml'
require 'fileutils'

api_host = ENV['API_HOST']
( api_host = 'localhost' ) if api_host.nil?
( api_host = 'localhost' ) if api_host == ''

api_port = ENV['API_PORT']
( api_port = 3000 ) if api_port.nil?
( api_port = 3000 ) if api_port == ''

API_HOST = api_host
API_PORT = api_port
API_PATH = '/api'

API_URL = "http://#{API_HOST}:#{API_PORT}#{API_PATH}"

credentials = YAML.load( File.read( File.dirname( __FILE__ ) + '/../credentials.yml' ) )

API_NAME     = credentials['name']
API_PASSWORD = credentials['password']

$: << File.dirname( __FILE__ ) + '/../lib'
require 'deltacloud'

def clean_fixtures
  FileUtils.rm_rf( File.dirname( __FILE__ ) + '/data' )
end

def reload_fixtures
  clean_fixtures
  FileUtils.cp_r( File.dirname( __FILE__) + '/fixtures', File.dirname( __FILE__ ) + '/data' )
end

$: << File.dirname( __FILE__ )
require 'shared/resources'
