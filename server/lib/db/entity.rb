module Deltacloud
  module Database

    class Entity < Sequel::Model

      attr_accessor :properties

      many_to_one :provider

      plugin :single_table_inheritance, :model
      plugin :timestamps, :create => :created_at

      def to_hash
        retval = {}
        retval.merge!(:name => self.name) if !self.name.nil?
        retval.merge!(:description => self.description) if !self.description.nil?
        retval.merge!(:property => JSON::parse(self.ent_properties)) if !self.ent_properties.nil?
        retval
      end

      def properties=(v)
        # Make sure @properties is always a Hash
        @properties = v || {}
      end

      def before_save
        self.ent_properties = properties.to_json
        super
      end

      def after_initialize
        if ent_properties
          self.properties = JSON::parse(ent_properties)
        else
          self.properties = {}
        end
      end

      # Load the entity for the CIMI::Model +model+, or create a new one if
      # none exists yet
      def self.retrieve(model)
        unless model.id
          raise "Can not retrieve entity for #{model.class.name} without an id"
        end
        h = model_hash(model)
        entity = Provider::lookup.entities_dataset.first(h)
        unless entity
          h[:provider_id] = Provider::lookup.id
          entity = Entity.new(h)
        end
        entity
      end

      private
      def self.model_hash(model)
        { :be_kind => model.class.name,
          :be_id => model.id.split("/").last }
      end
    end

  end
end
