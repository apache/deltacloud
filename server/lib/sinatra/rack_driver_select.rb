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

module Rack
  class DriverSelect

    def initialize(app, opts={})
      @app = app
      @opts = opts
    end

    HEADER_TO_ENV_MAP = {
      'HTTP_X_DELTACLOUD_DRIVER' => :driver,
      'HTTP_X_DELTACLOUD_PROVIDER' => :provider
    } unless defined?(HEADER_TO_ENV_MAP)

    def call(env)
      original_settings = { }
      req = Rack::Request.new(env)
      if req.params['api'] and req.params['api']['driver']
        env['HTTP_X_DELTACLOUD_DRIVER'] = req.params['api']['driver']
      end
      if req.params['api'] and req.params['api']['provider']
        env['HTTP_X_DELTACLOUD_PROVIDER'] = req.params['api']['provider']
      end
      HEADER_TO_ENV_MAP.each do |header, name|
        original_settings[name] = Thread.current[name]
        new_setting = extract_header(env, header)
        Thread.current[name] = new_setting if new_setting
      end

      @app.call(env)
    ensure
      original_settings.each { |name, value| Thread.current[name] = value }
    end

    def extract_header(env, header)
      env[header].downcase if env[header]
    end

  end
end
