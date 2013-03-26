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

require 'bundler/setup'
Bundler.require(:default, :development)

require 'require_relative' if RUBY_VERSION < '1.9'

Turn.config.format = :dot

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.command_name 'tests:units'
  SimpleCov.start do
    add_group "Models", "lib/deltacloud/client/models"
    add_group "Methods", "lib/deltacloud/client/methods"
    add_group "Helpers", "lib/deltacloud/client/helpers"
    add_group "Extensions", "lib/deltacloud/core_ext"
    add_filter "tests/"
  end
end

require 'minitest/autorun'
#
# Change this at will
#
DELTACLOUD_URL = ENV['API_URL'] || 'http://localhost:3001/api'
DELTACLOUD_USER = 'mockuser'
DELTACLOUD_PASSWORD = 'mockpassword'

def new_client
  Deltacloud::Client(DELTACLOUD_URL, DELTACLOUD_USER, DELTACLOUD_PASSWORD)
end

unless ENV['NO_VCR']
  require 'vcr'
  VCR.configure do |c|
    c.hook_into :faraday
    c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
    c.default_cassette_options = { :record => :new_episodes }
  end
end

require_relative './../lib/deltacloud/client'

def cleanup_instances(inst_arr)
  inst_arr.each do |i|
    i.reload!
    i.stop! unless i.is_stopped?
    i.destroy!
  end
end
