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

module CIMI::Model
  class Collection < Base

    class << self
      attr_accessor :entry_name
    end

    # Make sure the base schema gets cloned
    self.schema

    def initialize(values = {})
      if values[:entries]
        values[self.class.entry_name] = values.delete(:entries)
      end
      super(values)
    end

    def entries
      self[self.class.entry_name]
    end
    end

    def [](a)
      a = entry_name if a == :entries
      super(a)
    end

    def []=(a, v)
      a = entry_name if a == :entries
      super(a, v)
    end

    def self.xml_tag_name
      "Collection"
    end

    def self.generate(model_class)
      model_name = model_class.name.split("::").last
      coll_class = Class.new(CIMI::Model::Collection)
      CIMI::Model.const_set(:"#{model_name}Collection", coll_class)
      coll_class.entry_name = model_name.underscore.pluralize.to_sym
      entry_schema = model_class.schema
      coll_class.instance_eval do
        text :count
        array self.entry_name, :schema => entry_schema, :xml_name => model_name
        array :operations do
          scalar :rel, :href
        end
      end
      coll_class
    end
  end

  #
  # We need to reopen Base and add some stuff to avoid circular dependencies
  #
  class Base
    #
    # Toplevel collections
    #

    class << self

      attr_accessor :collection_class

      def acts_as_root_entity(opts = {})
        self.collection_class = Collection.generate(self)
        CIMI::Model.register_as_root_entity! self, opts
      end

      # Return a collection of entities
      def list(context)
        entries = find(:all, context)
        desc = "#{self.name.split("::").last} Collection for the #{context.driver.name.capitalize} driver"
        id = context.send("#{collection_class.entry_name}_url")
        collection_class.new(:id => id, :name => 'default',
                             :count => entries.size,
                             :entries => entries,
                             :description => desc)
      end
    end

    def self.all(context)
      find(:all, context)
    end
  end
end
