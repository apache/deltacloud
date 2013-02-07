module Deltacloud
  module Helpers

    require_relative '../../deltacloud/helpers/driver_helper.rb'

    module Database
      include Deltacloud::Helpers::Drivers

      DATABASE_COLLECTIONS = [ "machine_template", "address_template",
        "volume_configuration", "volume_template" ]

      def test_environment?
        Deltacloud.test_environment?
      end

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
