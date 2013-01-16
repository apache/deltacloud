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
        !entity.nil? && entity.destroy
      end

      def get_entity(model)
        current_db.entities_dataset.first(
          :be_kind => model.to_entity,
          :be_id => model.id,
        )
      end

      def current_provider
        Thread.current[:provider] || ENV['API_PROVIDER'] || 'default'
      end

      # This method allows to store things into database based on current driver
      # and provider.
      #

      def current_db
        Deltacloud::Database::Provider.find_or_create(:driver => driver_symbol.to_s, :url => current_provider)
      end

      def store_attributes_for(model, attrs={})
        return if test_environment? or model.nil? or attrs.empty?
        return if model.id.nil?

        unless entity = get_entity(model)
          entity = Deltacloud::Database::Entity.new(
            :provider_id => current_db.id,
            :be_id => model.id,
            :be_kind => model.to_entity
          )
        end

        entity.description = extract_attribute_value('description', attrs) if attrs.has_key? 'description'
        entity.name = extract_attribute_value('name', attrs) if attrs.has_key? 'name'

        if attrs.has_key? 'properties'
          entity.ent_properties = extract_attribute_value('properties', attrs).to_json
        elsif attrs.has_key? 'property'
          entity.ent_properties = extract_attribute_value('property', attrs).to_json
        end

        entity.exists? ? entity.save_changes : entity.save

        entity
      end

      # In XML serialization the values stored in attrs are arrays, dues to
      # XmlSimple. This method will help extract values from them
      #
      def extract_attribute_value(name, attrs={})
        return unless attrs[name]
        if name == 'property'
          attrs[name].is_a?(Array) ?
            attrs[name].inject({}) { |r, v| r[v['key']] = v['content']; r} :
            attrs[name]
        else
          attrs[name].is_a?(Array) ? attrs[name].first : attrs[name]
        end
      end

    end
  end

end
