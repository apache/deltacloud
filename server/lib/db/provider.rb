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

require_relative '../deltacloud/helpers/driver_helper'

module Deltacloud
  module Database

    class Provider < Sequel::Model
      extend Deltacloud::Helpers::Drivers

      one_to_many :entities
      one_to_many :machine_templates
      one_to_many :address_templates
      one_to_many :volume_templates
      one_to_many :volume_configurations

      # Find the DB provider set in the environment/request
      def self.lookup
        prov = Thread.current[:provider] || ENV['API_PROVIDER'] || 'default'
        find_or_create(:driver => current_driver_name, :url => prov)
      end

      private

      # In case this model is used outside the Deltacloud server (CIMI tests, CIMI
      # client, etc), the 'Deltacloud.default_frontend' is not initialized.
      # In that case we have to use the 'fallback' way to retrieve current
      # driver name.
      #
      def self.current_driver_name
        if Deltacloud.respond_to?(:default_frontend)
          self.driver_symbol.to_s
        else
          Thread.current[:driver] || ENV['API_DRIVER'] || 'mock'
        end
      end
    end

  end
end
