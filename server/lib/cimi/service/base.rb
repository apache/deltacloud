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

require 'xmlsimple'

require_relative '../helpers/database_helper'

# Service objects implement the server functionality of CIMI resources; in
# particular, these objects are responsible for interacting with the
# current driver. They use the CIMI::Model objects for (de)serialization
module CIMI::Service

  class Base

    # Extend the base model with database methods
    extend Deltacloud::Helpers::Database

    attr_reader :model, :context

    class << self
      def model_class
        CIMI::Model.const_get(name.split('::').last)
      end

      def model_name
        name.split('::').last.underscore.to_sym
      end

      def collection_name
        name.split('::').last.underscore.pluralize.to_sym
      end

      def inherited(subclass)
        # Decorate all the attributes of the model class
        schema = subclass.model_class.schema
        schema.attribute_names.each do |name|
          define_method(name) { self[name] }
          define_method(:"#{name}=") { |newval| self[name] = newval }
        end
      end

      def parse(context)
        req = context.request
        model = model_class.parse(req.body, req.content_type)
        new(context, :model => model)
      end

    end

    def initialize(context, opts)
      if opts[:values]
        @model = model_class.new(opts[:values])
      elsif opts[:model]
        @model = opts[:model]
      else
        @model = model_class.new({})
      end
      @context = context
      retrieve_entity
    end

    def model_class
      self.class.model_class
    end

    # Decorate some model methods
    def []=(a, v)
      v = (@model[a] = v)
      retrieve_entity if a == :id
      v
    end

    def [](a)
      @model[a]
    end

    def to_xml
      @model.to_xml
    end

    def to_json
      @model.to_json
    end

    def select_attributes(attr_list)
      @model.select_attributes(attr_list)
    end

    # Lookup a reference and return the corresponding model
    def resolve(ref)
      self.class.resolve(ref, context)
    end

    def self.resolve(ref, ctx)
      model = nil
      if ref.href?
        name = ref.class.superclass.name.split('::').last
        service_class = CIMI::Service::const_get(name)
        id = ref.href.split('/').last
        model = service_class.find(id, ctx)
      else
        # FIXME: if ref.href? we need to overwrite
        # attributes in model with ones from ref as long as they are present
        model = ref
      end
      model
    end

    def self.list(ctx)
      id = ctx.send("#{collection_name}_url")
      entries = find(:all, ctx)
      params = {}
      params[:desc] = "#{self.name.split("::").last} Collection for the #{ctx.driver.name.capitalize} driver"
      params[:add_url] = create_url(ctx)
      model_class.list(id, entries, params).select_by(ctx.params['$select']).filter_by(ctx.params['$filter'])
    end

    def self.create_url(ctx)
      cimi_create = "create_#{model_name}_url"
      dcloud_create = ctx.deltacloud_create_method_for(model_name)
      if(ctx.respond_to?(cimi_create) &&
         ctx.driver.respond_to?(dcloud_create)) || provides?(model_name)
        ctx.send(cimi_create)
      end
    end

    # Save the common attributes name, description, and properties to the
    # database
    def save
      if @entity
        before_save
        @entity.save
      end
      self
    end

    # Destroy the database attributes for this model
    def destroy
      @entity.destroy
      self
    end

    # FIXME: Kludge around the fact that we do not have proper *Create
    # objects that deserialize properties by themselves
    def extract_properties!(data)
      h = {}
      if data['property']
        # Data came from XML
        h = data['property'].inject({}) do |r,v|
          r[v['key']] = v['content']
          r
        end
      elsif data['properties']
        h = data['properties']
      end
      property ||= {}
      property.merge!(h)
    end

    def ref_id(ref_url)
      ref_url.split('/').last if ref_url
    end

    protected

    def attributes_to_copy
      [:name, :description]
    end

    def before_save
      attributes_to_copy.each { |a| @entity[a] = @model[a] }
      @entity.properties = @model.property
    end

    def after_retrieve
      attributes_to_copy.each { |a| @model[a] = @entity[a] }
      @model.property ||= {}
      @model.property.merge!(@entity.properties)
    end

    private

    # Load an existing database entity for this object, or create a new one
    def retrieve_entity
      if self.id
        @entity = Deltacloud::Database::Entity::retrieve(@model)
        if @entity.exists?
          after_retrieve
        end
      else
        @entity = nil
      end
    end

  end
end
