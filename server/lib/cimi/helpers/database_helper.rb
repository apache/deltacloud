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
        Deltacloud::Database::Entity.first(:be_kind => model.to_entity, :be_id => model.id, 'provider.driver' => driver_symbol.to_s, 'provider.url' => current_provider)
      end

      def current_provider
        Thread.current[:provider] || ENV['API_PROVIDER'] || 'default'
      end

      # This method allows to store things into database based on current driver
      # and provider.
      #

      def current_db
        Deltacloud::Database::Provider.first_or_create(:driver => driver_symbol.to_s, :url => current_provider)
      end

      def store_attributes_for(model, attrs={})
        return if test_environment? or model.nil? or attrs.empty?
        entity = get_entity(model) || current_db.entities.new(:be_kind => model.to_entity, :be_id => model.id)

        entity.description = extract_attribute_value('description', attrs) if attrs.has_key? 'description'
        entity.name = extract_attribute_value('name', attrs) if attrs.has_key? 'name'
        if attrs.has_key? 'properties'
          entity.ent_properties = extract_attribute_value('properties', attrs).to_json
        elsif attrs.has_key? 'property'
          entity.ent_properties = extract_attribute_value('property', attrs).to_json
        end

        entity.save! && entity
      end

      # In XML serialization the values stored in attrs are arrays, dues to
      # XmlSimple. This method will help extract values from them
      #
      def extract_attribute_value(name, attrs={})
        return unless attrs[name]
        attrs[name].is_a?(Array) ? attrs[name].first : attrs[name]
      end

    end
  end

end
