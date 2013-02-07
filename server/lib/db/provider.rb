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
        find_or_create(:driver => self.driver_symbol.to_s, :url => prov)
      end
    end

  end
end
