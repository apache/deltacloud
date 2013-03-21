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
    module HardwareProfile

      # Retrieve list of all hardware_profiles
      #
      # - filter_opts:
      #   - :id -> Filter hardware_profiles using their 'id'
      #
      def hardware_profiles(filter_opts={})
        from_collection :hardware_profiles,
          connection.get(api_uri('hardware_profiles'), filter_opts)
      end

      # Retrieve the given hardware_profile
      #
      # - hwp_id -> hardware_profile to retrieve
      #
      def hardware_profile(hwp_id)
        from_resource :hardware_profile,
          connection.get(api_uri("hardware_profiles/#{hwp_id}"))
      end

    end
  end
end
