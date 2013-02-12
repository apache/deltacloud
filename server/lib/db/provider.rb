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
