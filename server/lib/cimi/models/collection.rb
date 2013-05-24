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
  class Collection < Resource

    class << self
      attr_accessor :entry_name, :embedded

      def xml_tag_name
        'Collection'
      end

      def generate(model_class, opts = {})
        model_name = model_class.name.split("::").last
        scope = opts[:scope] || CIMI::Model
        coll_class = Class.new(CIMI::Model::Collection)
        scope.const_set(:"#{model_name}Collection", coll_class)
        coll_class.entry_name = model_name.underscore.pluralize.to_sym
        coll_class.embedded = opts[:embedded]
        entry_schema = model_class.schema
        coll_class.instance_eval do
          text :id
          scalar :href
          text :count
          scalar :href if opts[:embedded]
          array self.entry_name, :schema => entry_schema, :xml_name => model_name
          array :operations do
            scalar :rel, :href
          end
        end
        coll_class
      end

    end

    # Make sure the base schema gets cloned
    schema

    # You can initialize collection by passing the Hash representation of the
    # collection or passing another Collection object.
    #
    def initialize(values = {})
      if values.kind_of?(Hash)
        if values[:entries]
          values[self.class.entry_name] = values.delete(:entries)
        end
        values[self.class.entry_name] ||= []
        super(values)
      else
        super
      end
    end

    def entries
      self[self.class.entry_name]
    end

    # Prepare to serialize
    def prepare
      self.count = self.entries.size
      if self.class.embedded
        ["id", "href"].each { |a| self[a] = nil if self[a] == "" }
        # Handle href and id, which are really just aliases of one another
        unless self.href || self.id
          raise "Collection #{self.class.name} must have one of id and href set"
        end
        self.href ||= self.id
        self.id ||= self.href
      end
    end

    def [](a)
      a = self.class.entry_name if a == :entries
      super(a)
    end

    def []=(a, v)
      a = self.class.entry_name if a == :entries
      super(a, v)
    end

    def select_attributes(attr_list)
      self[self.class.entry_name] = entries.map do |e|
        e.select_attributes(attr_list)
      end
      self
    end
  end

  module CollectionMethods

    def collection_class=(klass)
      @collection_class = klass
    end

    def collection_class
      @collection_class
    end

    # Return a collection of entities
    def list(id, entries, params = {})
      params[:id] = id
      if params[:system]
        entries.each do |sys|
          entry_id = sys.model.id
          sys.model.attribute_values.each do |k,v|
            if v.is_a? CIMI::Model::Collection
              v.href ||= "#{entry_id}/#{k.to_s}"
            end
          end
        end
      end
      params[:entries] = entries
      params[:count] = params[:entries].size
      if params[:add_url]
        params[:operations] ||= []
        params[:operations] << { :rel => "add", :href => params.delete(:add_url) }
      end
      collection_class.new(params)
    end
  end
end
