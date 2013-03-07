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

module Deltacloud::Client
  module Methods
    module BackwardCompatibility

      # Backward compatibility methods provides fallback for the
      # old deltacloud-client gem.
      #
      #
      def api_host
        connection.url_prefix.host
      end

      def api_port
        connection.url_prefix.port
      end

      def connect(&block)
        yield self.clone
      end

      def with_config(opts, &block)
        yield inst = use(
          opts[:driver],
          opts[:username],
          opts[:password],
          opts[:provider]
        ) if block_given?
        inst
      end

      def use_driver(new_driver, opts={})
        with_config(opts.merge(:driver => new_driver))
      end

      alias_method :"use_config!", :use_driver

      def discovered?
        true unless entrypoint.nil?
      end

      module ClassMethods

        def valid_credentials?(api_user, api_password, api_url, opts={})
          args = {
            :api_user => api_user,
            :api_password => api_password,
            :url => api_url
          }
          args.merge!(:providers => opts[:provider]) if opts[:provider]
          Deltacloud::Client::Connection.new(args).valid_credentials?
        end

      end

    end
  end
end
