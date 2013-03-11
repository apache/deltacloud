# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

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
        super
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
          entity = @@model_entity_map[model.class].new(h)
        end
        entity
      end

      def self.inherited(subclass)
        super
        # Build a map from CIMI::Model class to Entity subclass. This only
        # works if the two classes have the same name in their respective
        # modules.
        # The map is used to determine what Entity subclass to instantiate
        # for a given model in +retrieve+
        @@model_entity_map ||= Hash.new(Entity)
        n = subclass.name.split('::').last
        if k = CIMI::Model::const_get(n)
          @@model_entity_map[k] = subclass
        end
      end

      private
      def self.model_hash(model)
        { :be_kind => model.class.name,
          :be_id => model.id.split("/").last }
      end
    end

  end
end
