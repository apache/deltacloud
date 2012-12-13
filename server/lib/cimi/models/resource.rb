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

require_relative '../helpers/filter_helper'
require_relative '../helpers/select_helper'

module CIMI
  module Model
    class Resource

      extend CIMI::Model::Schema::DSL
      include CIMI::Helpers::SelectResourceMethods
      include CIMI::Helpers::FilterResourceMethods

      #
      # We keep the values of the attributes in a hash
      #
      attr_reader :attribute_values

      CMWG_NAMESPACE = "http://schemas.dmtf.org/cimi/1"

      #
      # Factory methods
      #
      def initialize(values = {})
        names = self.class.schema.attribute_names
        @select_attrs = values[:select_attr_list] || []
        # Make sure we always have the :id of the entity even
        # the $select parameter is used and :id is filtered out
        #
        @base_id = values[:base_id] || values[:id]
        @attribute_values = names.inject(OrderedHash.new) do |hash, name|
          hash[name] = self.class.schema.convert(name, values[name])
          hash
        end
      end

      # The CIMI::Model::Resource class methods
      class << self

        def base_schema
          @schema ||= CIMI::Model::Schema.new
        end

        def clone_base_schema
          @schema_duped = true
          @schema = superclass.base_schema.deep_clone
        end

        def base_schema_cloned?
          @schema_duped
        end

        private :clone_base_schema, :base_schema_cloned?

        # If the model is inherited by another model, we want to clone
        # the base schema instead of using the parent model schema, which
        # might be modified
        #
        def inherited(child)
          child.instance_eval do
            def schema
              base_schema_cloned? ? @schema : clone_base_schema
            end
          end
        end

        def add_attributes!(names, attr_klass, &block)
          if self.respond_to? :schema
            schema.add_attributes!(names, attr_klass, &block)
          else
            base_schema.add_attributes!(names, attr_klass, &block)
          end
          names.each do |name|
            define_method(name) { self[name] }
            define_method(:"#{name}=") { |newval| self[name] = newval }
          end
        end

        # Return Array of links to current CIMI object
        #
        def all_uri(context)
          self.all(context).map { |e| { :href => e.id } }
        end

        # Construct a new object from the XML representation +xml+
        def from_xml(text)
          xml = XmlSimple.xml_in(text, :force_content => true)
          model = self.new
          @schema.from_xml(xml, model)
          model
        end

        # Construct a new object
        def from_json(text)
          json = JSON::parse(text)
          model = self.new
          @schema.from_json(json, model)
          model
        end

        def parse(text, content_type)
          if content_type == "application/xml"
            from_xml(text)
          elsif content_type == "application/json"
            from_json(text)
          else
            raise "Can not parse content type #{content_type}"
          end
        end

        #
        # Serialize
        #

        def xml_tag_name
          self.name.split("::").last
        end

        def resource_uri
          CMWG_NAMESPACE + "/" + self.name.split("::").last
        end

        def to_json(model)
          json = @schema.to_json(model)
          json[:resourceURI] = resource_uri
          JSON::unparse(json)
        end

        def to_xml(model)
          xml = @schema.to_xml(model)
          xml["xmlns"] = CMWG_NAMESPACE
          xml["resourceURI"] = resource_uri
          XmlSimple.xml_out(xml, :root_name => xml_tag_name)
        end
      end

      # END of class methods

      def [](a)
        @attribute_values[a]
      end

      def []=(a, v)
        return @attribute_values.delete(a) if v.nil?
        @attribute_values[a] = self.class.schema.convert(a, v)
      end

      # Apply the $select options to all sub-collections and prepare then
      # to serialize by setting correct :href and :id attributes.
      #
      def prepare
        self.class.schema.collections.map { |coll| coll.name }.each do |n|
          if @select_attrs.empty? or @select_attrs.include?(n)
            self[n].href = "#{self.base_id}/#{n}" if !self[n].href
            self[n].id = "#{self.base_id}/#{n}" if !self[n].entries.empty?
          else
            self[n] = nil
          end
        end
      end

      def base_id
        self.id || @base_id
      end

      def to_json
        self.class.to_json(self)
      end

      def to_xml
        self.class.to_xml(self)
      end

    end

  end
end
