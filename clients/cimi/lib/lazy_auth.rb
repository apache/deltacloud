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

require 'sinatra/base'

# Lazy Basic HTTP authentication. Authentication is only forced when the
# credentials are actually needed.
module Sinatra
  module LazyAuth
    class LazyCredentials
      def initialize(app)
        @app = app
        @provided = false
      end

      def user
        credentials!
        @user
      end

      def password
        credentials!
        @password
      end

      def provided?
        @provided
      end

      def credentials!
        if ENV["API_USER"] && ENV["API_PASSWORD"]
          @user = ENV["API_USER"]
          @password = ENV["API_PASSWORD"]
          @provided = true
        end
        unless provided?
          auth = Rack::Auth::Basic::Request.new(@app.request.env)
          unless auth.provided? && auth.basic? && auth.credentials
            @app.authorize!
          end
          @user = auth.credentials[0]
          @password = auth.credentials[1]
          @provided = true
        end
      end

    end

    def authorize!
      r = "cimi@localhost"
      response['WWW-Authenticate'] = %(Basic realm="#{r}")
      throw(:halt, [401, "Not authorized\n"])
    end

    # Request the current user's credentials. Actual credentials are only
    # requested when an attempt is made to get the user name or password
    def credentials
      LazyCredentials.new(self)
    end
  end
end
