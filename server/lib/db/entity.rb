module Deltacloud
  module Database

    class BaseEntity
      include DataMapper::Resource

      belongs_to :provider

      property :id, Serial
      property :type, Discriminator

      property :be_kind, String, :required => true # => Machine, MachineImage, ...
      property :be_id, String # => Original Machine 'id'

      timestamps :created_at, :updated_on
    end

    class Entity < BaseEntity

      belongs_to :provider

      property :name, String
      property :description, String
      property :ent_properties, Json

      def to_hash
        retval = {}
        retval.merge!(:name => self.name) if !self.name.nil?
        retval.merge!(:description => self.description) if !self.description.nil?
        retval.merge!(:property => self.ent_properties) if !self.ent_properties.nil?
        retval
      end

    end

  end
end
