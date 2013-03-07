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
    module Driver

      # Retrieve list of all drivers
      #
      # Filter options:
      #
      # - :id -> Filter drivers using their 'id'
      # - :state -> Filter drivers  by their 'state'
      #
      def drivers(filter_opts={})
        from_collection(
          :drivers,
          connection.get(api_uri('drivers'), filter_opts)
        )
      end

      # Retrieve the given driver
      #
      # - driver_id -> Driver to retrieve
      #
      def driver(driver_id)
        from_resource(
          :driver,
          connection.get(api_uri("drivers/#{driver_id}"))
        )
      end

      # List of the current driver providers
      #
      def providers
        driver(current_driver).providers
      end

    end

  end
end
