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
  # Automatically sets the X-CIMI-Specification-Version header on all responses.
  #
  class CIMI

    def initialize(app, no_cache_control = nil, cache_control = nil)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers['X-CIMI-Specification-Version'] = '0.0.66'
      [status, headers, body]
    end

  end
end

