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

unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

require_relative './deltacloud/core_ext'
require_relative './sinatra/rack_logger'

module Deltacloud

  def self.config
    @config ||= {}
  end

  def self.configure(frontend=:deltacloud, &block)
    frontend = frontend.to_sym
    config[frontend] = Server.new(&block)
    self
  end

  def self.[](frontend=:deltacloud)
    config[frontend.to_sym]
  end

  def self.require_frontend!(frontend=:deltacloud)
    frontend = frontend.to_sym
    require_relative File.join(frontend.to_s, 'server.rb')
    Deltacloud[frontend].klass eval('::'+Deltacloud[frontend].klass)
  end

  class Server

    attr_reader :root_url
    attr_reader :version
    attr_reader :klass
    attr_reader :logger

    def initialize(opts={}, &block)
      @root_url = opts[:root_url]
      @version = opts[:version]
      @klass = opts[:klass]
      @logger = opts[:logger] || Rack::DeltacloudLogger
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

    def logger(logger=nil)
      return @logger if logger.nil?
      @logger = logger
    end

  end

end
