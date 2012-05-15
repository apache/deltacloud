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

  def self.config(conf=nil)
    @config ||= conf
  end

  def self.configure(&block)
    config(Server.new(&block))
    self
  end

  def self.[](item)
    config.send(item)
  end

  def self.require_frontend!
    ENV['API_FRONTEND'] ||= 'deltacloud'
    require File.join(File.dirname(__FILE__), ENV['API_FRONTEND'], 'server.rb')
    config.klass eval(self[:klass])
  end

  class Server

    attr_reader :root_url
    attr_reader :version
    attr_reader :klass

    def initialize(opts={}, &block)
      @root_url = opts[:root_url]
      @version = opts[:version]
      @klass = opts[:klass]
      instance_eval(&block)
    end

    def root_url(url=nil)
      return @root_url if url.nil?
      raise '[Core] The server URL must start with /' unless url =~ /^\//
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

  end

end
