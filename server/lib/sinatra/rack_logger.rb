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

require_relative 'body_proxy'

# This module is based on Rack::CommonLogger[1]
# Copyright (C) 2007, 2008, 2009, 2010 Christian Neukirchen <purl.org/net/chneukirchen>
#
# [1] https://github.com/rack/rack/blob/master/lib/rack/commonlogger.rb

module Rack
  # Rack::CommonLogger forwards every request to an +app+ given, and
  # logs a line in the Apache common log format to the +logger+, or
  # rack.errors by default.
  class DeltacloudLogger

    def self.log_path(path=nil)
      @log_file ||= path
    end

    def self.verbose?
      @verbose
    end

    def self.verbose(v=nil)
      @verbose ||= v
    end

    def self.setup(path, be_verbose=false)
      verbose(be_verbose)
      return self if path.nil?
      dir = ::File.dirname(path)
      if ::File.exists?(dir) and ::File.writable?(dir)
        log_path(path)
      else
        warn "Warning: The log directory (#{dir}) is not writeable."
      end
      self
    end

    def self.error(code, &block)
      @logger ||= ::Logger.new(log_path || $stdout)
      @logger.error(code, &block)
    end

    # Common Log Format: http://httpd.apache.org/docs/1.3/logs.html#common
    # lilith.local - - [07/Aug/2006 23:58:02] "GET / HTTP/1.1" 500 -
    #             %{%s - %s [%s] "%s %s%s %s" %d %s\n} %
    FORMAT = %{%s - %s [%s] "%s %s%s %s" %d %s %0.4f\n}

    VERBOSE_FORMAT = %{%s - %s [%s] "%s %s%s%s %s" %s %s %d %s %0.4f\n}

    def initialize(app, logger=nil)
      @app = app
      unless self.class.log_path.nil?
        @logger = ::Logger.new(self.class.log_path)
      else
        @logger = logger
      end
    end

    def call(env)
      began_at = Time.now
      status, header, body = @app.call(env)
      header = Utils::HeaderHash.new(header)
      body = BodyProxy.new(body) do
        self.class.verbose? ? verbose_log(env, status, header, began_at) : log(env, status, header, began_at)
      end
      [status, header, body]
    end

    private

    def verbose_log(env, status, header, began_at)
      now = Time.now
      length = extract_content_length(header)
      params = env['rack.request.form_hash'].nil? ? '' : ' '+env['rack.request.form_hash'].to_json

      logger = @logger || env['rack.errors']
      logger << VERBOSE_FORMAT % [
        env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
        env["REMOTE_USER"] || "-",
        now.strftime("%d/%b/%Y %H:%M:%S"),
        env["REQUEST_METHOD"],
        env["PATH_INFO"],
        env["QUERY_STRING"].empty? ? '' : "?"+env["QUERY_STRING"],
        params,
        env["HTTP_VERSION"],
        env['HTTP_X_DELTACLOUD_DRIVER'] || ENV['API_DRIVER'] || 'mock',
        env['HTTP_X_DELTACLOUD_PROVIDER'] || ENV['API_PROVIDER'] || '-',
        status.to_s[0..3],
        length,
        now - began_at ]
    end

    def log(env, status, header, began_at)
      now = Time.now
      length = extract_content_length(header)

      logger = @logger || env['rack.errors']
      logger << FORMAT % [
        env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
        env["REMOTE_USER"] || "-",
        now.strftime("%d/%b/%Y %H:%M:%S"),
        env["REQUEST_METHOD"],
        env["PATH_INFO"],
        env["QUERY_STRING"].empty? ? "" : "?"+env["QUERY_STRING"],
        env["HTTP_VERSION"],
        status.to_s[0..3],
        length,
        now - began_at ]
    end

    def extract_content_length(headers)
      value = headers['Content-Length'] or return '-'
      value.to_s == '0' ? '-' : value
    end
  end
end

