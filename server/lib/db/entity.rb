module Deltacloud
  module Database

    class Entity
      include DataMapper::Resource

      belongs_to :provider

      property :id, Serial
      property :be_kind, String, :required => true # => Machine, MachineImage, ...
      property :be_id, String, :required => true # => Original Machine 'id'

      property :ent_properties, Json

      property :name, String
      property :description, String

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
