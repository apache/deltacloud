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

require 'require_relative'

require_relative 'core_ext'
require_relative 'models'
require_relative 'drivers'
require_relative 'helpers/driver_helper'

module TestPoller
  # This method will pool the resource until condition is true
  # Will raise 'Timeout' when it reach retry count
  #
  # default opts[:retries] => 10
  # default opts[:time_between_retry] => 10 (seconds)
  # default opts[:timeout] => 60 (seconds) -> single request timeout
  #
  # opts[:before] => Proc -> executed 'before' making each request
  # opts[:after] => Proc -> executed 'after' making each request
  #
  def wait_for!(driver, opts={}, &block)
    opts[:retries] ||= 10
    opts[:time_between_retry] ||= 10
    opts[:timeout] ||= 60
    opts[:method] ||= self.class.name.downcase.to_sym
    opts[:retries].downto(0) do |r|
      result = begin
        timeout(opts[:timeout]) do
          if opts[:before]
            new_instance = opts[:before].call(r) { driver.send(opts[:method], :id => self.id) }
          else
            new_instance = driver.send(opts[:method], :id => self.id)
          end
          ((yield new_instance) == true) ? new_instance : false
        end
      rescue Timeout::Error
        false
      ensure
        opts[:after].call(r) if opts[:after]
      end
      return result unless result == false
      sleep(opts[:time_between_retry])
    end
    raise Timeout::Error
  end
end

class Instance; include TestPoller; end
class Image; include TestPoller; end
class StorageSnapshot; include TestPoller; end

module Deltacloud

  API_VERSION = '1.0.0'

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
      if backend.respond_to? :providers
        backend.providers(@credentials)
      else
        Deltacloud.drivers[current_driver.to_sym]
      end
    end

    def provider(opts={})
      providers.find { |p| p.id == opts[:id] }
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
