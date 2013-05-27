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

# The requires are here because this file could be used to initialize
# the Deltacloud Rack middleware
#
require 'require_relative' if RUBY_VERSION < '1.9'
require 'json/pure'

require_relative './deltacloud/core_ext'
require_relative './sinatra/rack_logger'
require_relative './deltacloud/version'

module Deltacloud

  def self.config
    @config ||= {}
  end

  def self.configure(frontend=:deltacloud, &block)
    frontend = frontend.to_sym
    config[frontend] ||= Server.new(frontend, &block)
    self
  end

  def self.[](frontend=:deltacloud)
    config[frontend.to_sym]
  end

  def self.require_frontend!(frontend=:deltacloud)
    frontend = frontend.to_sym
    return false if frontend_required?(frontend)
    require_relative File.join(frontend.to_s, 'server.rb')
    Deltacloud[frontend].klass eval('::'+Deltacloud[frontend].klass)
  end

  def self.enabled_frontends
    @config.keys.select { |k| frontend_required?(k) }.map { |f| Deltacloud[f] }
  end

  def self.frontend_required?(frontend)
    true unless Deltacloud[frontend].klass.kind_of? String
  end

  def self.default_frontend(frontend=nil)
    @default_frontend = frontend unless frontend.nil?
    raise "Could not determine default API frontend" if @default_frontend.nil? and !config[:deltacloud]
    @default_frontend || config[:deltacloud]
  end

  def self.generate_routes
    frontends.inject({}) do |result, frontend|
      frontend = frontend.strip
      if Deltacloud[frontend.to_sym].nil?
        puts "ERROR: Unknown frontend (#{frontend}). Valid values are 'deltacloud,cimi,ec2'"
        exit(1)
      end
      Deltacloud[frontend.to_sym].require!
      result[Deltacloud[frontend].root_url] = Deltacloud[frontend].klass
      result
    end
  end

  def self.need_database?
    frontends.include?('cimi') || ENV['RACK_ENV'] == 'test'
  end

  require 'sinatra/base'
  require_relative './deltacloud/helpers/deltacloud_helper'
  require_relative './sinatra/rack_accept'

  class IndexApp < Sinatra::Base

    helpers Deltacloud::Helpers::Application
    register Rack::RespondTo

    set :views, File.join(File.dirname(__FILE__), '..', 'views')

    get '/robots.txt' do
      send_file File.join('public', 'robots.txt')
    end

    get '/' do
      respond_to do |format|
        format.xml { haml :'index', :layout => false }
        format.html { haml :'index', :layout => false }
      end
    end
  end

  class Server

    attr_reader :name
    attr_reader :root_url
    attr_reader :version
    attr_reader :klass
    attr_reader :logger
    attr_reader :default_driver

    def initialize(frontend, opts={}, &block)
      @name=frontend.to_sym
      @root_url = opts[:root_url]
      @version = opts[:version]
      @klass = opts[:klass]
      @logger = opts[:logger] || Rack::DeltacloudLogger.setup(ENV['API_LOG'], ENV['API_VERBOSE'])
      @default_driver = opts[:default_driver] || ENV['API_DRIVER'] || :mock
      instance_eval(&block)
    end

    def root_url(url=nil)
      return @root_url if url.nil?
      raise "[Core] The server URL must start with / (#{url})" unless url =~ /^\//
      @root_url = url
    end

    def version(version=nil)
      return @version if version.nil?
      @version = version
    end

    def klass(k=nil)
      return @klass if k.nil?
      @klass = k
    end

    def default_driver(drv=nil)
      return @default_driver if drv.nil?
      @default_driver = drv
    end

    def logger(logger=nil)
      return @logger if logger.nil?
      @logger = logger
    end

    # Require the Deltacloud API Rack middleware
    #
    # opts[:initialize] = true will require 'initialize.rb'
    #
    def require!(opts={})
      require_relative './initializers/mock_initialize' if opts[:mock_initialize]
      Deltacloud.require_frontend!(@name)
    end

    def default_frontend!
      Deltacloud.default_frontend(self)
    end

  end

end
