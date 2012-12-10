module Deltacloud
  module Helpers

    module Database

      def test_environment?
        Deltacloud.test_environment?
      end

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
