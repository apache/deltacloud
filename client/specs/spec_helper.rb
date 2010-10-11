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

require 'rubygems'
require 'yaml'
require 'fileutils'

api_host = ENV['API_HOST']
( api_host = 'localhost' ) if api_host.nil?
( api_host = 'localhost' ) if api_host == ''

api_port = ENV['API_PORT']
( api_port = 3001 ) if api_port.nil?
( api_port = 3001 ) if api_port == ''

API_HOST = api_host
API_PORT = api_port
API_PATH = '/api'

API_URL = "http://#{API_HOST}:#{API_PORT}#{API_PATH}"
API_URL_REDIRECT = "http://#{API_HOST}:#{API_PORT}"
API_NAME     = 'mockuser'
API_PASSWORD = 'mockpassword'

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
