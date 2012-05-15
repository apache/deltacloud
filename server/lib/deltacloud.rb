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
require 'ostruct'

load File.join(File.dirname(__FILE__), 'deltacloud/core_ext.rb')

require_relative 'deltacloud/core_ext/string'
require_relative 'deltacloud/core_ext/array'
require_relative 'deltacloud/core_ext/hash'
require_relative 'deltacloud/core_ext/integer'
require_relative 'deltacloud/core_ext/proc'
require_relative 'deltacloud/models'
require_relative 'deltacloud/drivers'
require_relative 'deltacloud/helpers/driver_helper'

module Deltacloud

  API_VERSION = '0.5.0'

  def self.drivers
    Drivers.driver_config
  end

  class Library
    include Helpers::Drivers

    attr_reader :backend, :credentials

    def initialize(driver_name, opts={}, &block)
      Thread.current[:driver] = driver_name.to_s
      Thread.current[:provider] = opts[:provider]
      @backend = driver
      opts[:user] ||= 'mockuser'
      opts[:password] ||= 'mockpassword'
      @credentials = OpenStruct.new(:user => opts[:user], :password => opts[:password])
      yield backend if block_given?
    end

    def version
      Deltacloud::API_VERSION
    end

    def current_provider
      Thread.current[:provider]
    end

    def current_driver
      Thread.current[:driver]
    end

    def providers
      Deltacloud.drivers[current_driver.to_sym]
    end

    def method_missing(name, *args)
      return super unless backend.respond_to? name
      begin
        params = ([@credentials] + args).flatten
        backend.send(name, *params)
      rescue ArgumentError
        backend.send(name, *args)
      end
    end

  end

  def self.new(driver_name, opts={}, &block)
    Library.new(driver_name, opts, &block)
  end

end
