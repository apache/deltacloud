module Deltacloud
  module Database

    class Entity < Sequel::Model

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

    end

  end
end
