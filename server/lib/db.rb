module Deltacloud

  def self.test_environment?
    ENV['RACK_ENV'] == 'test'
  end

  module Database
    def test_environment?
      Deltacloud.test_environment?
    end
  end

  unless test_environment?
    require 'data_mapper'
    require_relative './db/provider'
    require_relative './db/entity'
    require_relative './db/machine_template'
  end

  DATABASE_LOCATION = ENV['DATABASE_LOCATION'] || "/var/tmp/deltacloud-mock-#{ENV['USER']}/db.sqlite"

  def self.initialize_database
    DataMapper::Logger.new($stdout, :debug)
    dbdir = File::dirname(DATABASE_LOCATION)
    unless File::directory?(dbdir)
      FileUtils::mkdir(dbdir)
    end
    DataMapper::setup(:default, "sqlite://#{DATABASE_LOCATION}")
    DataMapper::finalize
    DataMapper::auto_upgrade!
  end

  module Helpers
    module Database
      include Deltacloud::Database

      def store_attributes_for(model, values={})
        return if test_environment?
        return if model.nil? or values.empty?
        current_db.entities.first_or_create(:be_kind => model.to_entity, :be_id => model.id).update(values)
      end

      def load_attributes_for(model)
        return {} if test_environment?
        entity = get_entity(model)
        entity.nil? ? {} : entity.to_hash
      end

      def delete_attributes_for(model)
        return if test_environment?
        entity = get_entity(model)
        !entity.nil? && entity.destroy!
      end

      def get_entity(model)
        current_db.entities.first(:be_kind => model.to_entity, :be_id => model.id)
      end

      def current_provider
        Thread.current[:provider] || ENV['API_PROVIDER'] || 'default'
      end

      # This method allows to store things into database based on current driver
      # and provider.
      #
      def current_db
        Provider.first_or_create(:driver => driver_symbol.to_s, :url => current_provider)
      end

    end
  end

end

Deltacloud::initialize_database unless Deltacloud.test_environment?
