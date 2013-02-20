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
  module Helpers

    require_relative '../../deltacloud/helpers/driver_helper.rb'

    module Database
      include Deltacloud::Helpers::Drivers

      DATABASE_COLLECTIONS = [ "machine_template", "address_template",
        "volume_configuration", "volume_template" ]

     def provides?(entity)
       return true if DATABASE_COLLECTIONS.include? entity
       return false
     end

      def current_provider
        Thread.current[:provider] || ENV['API_PROVIDER'] || 'default'
      end

      # This method allows to store things into database based on current driver
      # and provider.
      #

      def current_db
        Deltacloud::Database::Provider.lookup
      end
    end
  end

end
