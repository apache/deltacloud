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

module Deltacloud

  def self.frontend_enabled?(frontend)
    frontends.include? frontend.to_s
  end

  def self.frontends
    ENV['API_FRONTEND'] ||= 'deltacloud'
    ENV['API_FRONTEND'].split(',')
  end

  # Deltacloud is in production mode when it is launched from the
  # GEM_PATH or from the RPM install path.
  # IN that case, we require the system installed gems instead of
  # using Bundler.
  #
  def self.is_production?
    current_path = File.expand_path(File.dirname(__FILE__))
    return true if Gem.path[0..Gem.path.length] == current_path
    return true if current_path[0..10] == '/usr/share'
    false
  end

  # Deltacloud is in development mode when it is launched from GIT
  # repository (./bin/deltacloudd)
  # In this case we use Bundler to load all dependencies.
  #
  def self.is_development?
    !is_production? and !is_test?
  end

  # Deltacloud is in test mode when it is launched using unit tests.
  # In this case we use Bundler to load all dependencies and also dependencies
  # needed for executing tests (:test group)
  #
  def self.is_test?
    true if ENV['RACK_ENV'] == 'test'
  end

end

if Deltacloud.is_production?
  require 'json/pure'
  require 'haml'
  require 'sinatra/base'
  require 'sinatra/rabbit'
  require 'rack/accept'
  require 'eventmachine'
  require 'base64'
  require 'open3'
  require 'net/ssh'
  require 'ipaddr'
  if Deltacloud.frontend_enabled? :cimi
    require 'xmlsimple'
    require 'sequel'
    require 'uuidtools'
    (RUBY_PLATFORM == 'java') ? require('jdbc/sqlite3') : require('sqlite3')
  end
end

if Deltacloud.is_development?
  require 'bundler'
  Bundler.require(:default)
end

if Deltacloud.is_test?
  require 'bundler'
  Bundler.require(:default, :test, :jenkins)
  require 'singleton'
  require 'pp'
end

# In jRuby we need to load the JDBC driver explicitely
#
if RUBY_PLATFORM == 'java' && Deltacloud.frontends.include?('cimi')
  Jdbc::SQLite3.load_driver
end

# Ruby standard libraries.
# These are not managed by bundler/rubygems.

require 'socket'
require 'tempfile'
require 'logger'
require 'fileutils'
require 'cgi'
require 'digest/md5'
require 'digest/sha1'
require 'net/http'
require 'net/https'
require 'erb'
require 'benchmark'
require 'time'
require 'ostruct'
require 'yaml'
