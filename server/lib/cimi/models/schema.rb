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
#

require_relative "../../deltacloud/core_ext"

# The smarts of converting from XML and JSON into internal objects
class CIMI::Model::Schema

  #
  # Attributes describe how we extract values from XML/JSON
  #
  class Attribute
    attr_reader :name, :xml_name, :json_name
    attr_reader :required

    def initialize(name, opts = {})
      @name = name
      @xml_name = opts[:xml_name] || name.to_s.camelize(true)
      @json_name = opts[:json_name] || name.to_s.camelize(true)
      @required = opts[:required] || false
    end

    def from_xml(xml, model)
      model[@name] = xml[@xml_name].first if xml.has_key?(@xml_name)
    end

    def from_json(json, model)
      model[@name] = json[@json_name]
    end

    def to_xml(model, xml)
      xml[@xml_name] = [model[@name]] if model[@name]
    end

    def to_json(model, json)
      json[@json_name] = model[@name] if model and model[@name]
    end

    def convert(value)
      value
    end

    def required?
      @required
    end

    def valid?(value)
      !value.nil? and !value.to_s.empty?
    end
  end

  class Scalar < Attribute
    def initialize(name, opts)
      @text = opts[:text]
      if ! [nil, :nested, :direct].include?(@text)
        raise "text option for scalar must be :nested or :direct"
      end
      super(name, opts)
    end

    def text?; @text; end

    def nested_text?; @text == :nested; end

    def from_xml(xml, model)
      case @text
        when :nested then model[@name] = xml[@xml_name].first["content"] if xml[@xml_name]
        when :direct then model[@name] = xml["content"]
        else model[@name] = xml[@xml_name]
      end
    end

    def to_xml(model, xml)
      return unless model
      return unless model[@name]
      case @text
        when :nested then xml[@xml_name] = [{ "content" => model[@name] }]
        when :direct then xml["content"] = model[@name]
        else xml[@xml_name] = model[@name]
      end
    end
  end

  class Struct < Attribute

    attr_accessor :schema

    def initialize(name, opts={}, &block)
      content = opts[:content]
      super(name, opts)
      if opts[:schema]
        if block_given?
          raise "Cannot provide :schema option and a block"
        end
        @schema = opts[:schema]
      else
        @schema = CIMI::Model::Schema.new
        @schema.instance_eval(&block) if block_given?
        @schema.scalar(content, :text => :direct, :required => opts[:required]) if content
      end
    end

    def from_xml(xml, model)
      xml = xml.has_key?(xml_name) ? xml[xml_name].first : {}
      model[name] = convert_from_xml(xml)
    end

    def from_json(json, model)
      json = json.has_key?(json_name) ? json[json_name] : {}
      model[name] = convert_from_json(json)
    end

    def to_xml(model, xml)
      conv = convert_to_xml(model[name])
      xml[xml_name] = [conv] unless conv.empty?
    end

    def to_json(model, json)
      conv = convert_to_json(model[name])
      json[json_name] = conv unless conv.empty?
    end

    def convert_from_xml(xml)
      sub = struct.new
      @schema.from_xml(xml, sub)
      sub
    end

    def convert_from_json(json)
      sub = struct.new
      @schema.from_json(json, sub)
      sub
    end

    def convert_to_xml(model)
      xml = OrderedHash.new
      @schema.to_xml(model, xml)
      xml
    end

    def convert_to_json(model)
      json = {}
      @schema.to_json(model, json)
      json
    end

    def valid?(value)
      @schema.required_attributes.all? { |a|
        a.valid?(value.send(a.name))
      }
    end

    def convert(value)
      if @klass
        @klass.new(value || {})
      else
        super(value)
      end
    end

    private
    def struct
      if @klass
        @klass
      else
        @struct_class ||= ::Struct.new(nil, *@schema.attribute_names)
      end
    end
  end

  class Ref < CIMI::Model::Schema::Struct

    def initialize(name, opts={}, &block)
      raise 'The :class attribute must be set' unless opts[:class]
      refname = "#{opts[:class].name.split("::").last}Ref"
      if CIMI::Model::const_defined?(refname)
        @klass = CIMI::Model::const_get(refname)
      else
        @klass = Class.new(opts[:class]) do |m|
          scalar :href

          def ref_id(ctx)
            # FIXME: We should use ctx's routes to split
            # out the :id
            href.split('/').last
          end

          def find(ctx)
            klass.find(ref_id(ctx), ctx)
          end

          def klass
            self.class.superclass
          end
        end
        CIMI::Model::const_set(refname, @klass)
      end
      @klass.class_eval { def href?; !href.nil?; end }
      opts[:schema] = @klass.schema
      super(name, opts, &block)
    end

    # The 'ref' could be the reference to a CIMI entity or the full CIMI
    # entity representation.
    #
    def valid?(value)
      !value.href.nil? || @klass.schema.required_attributes.all? { |a|
        a.valid?(value.send(a.name))
      }
    end
  end

  class Array < Attribute

    attr_accessor :struct

    # For an array :funThings, we collect all <funThing/> elements (XmlSimple
    # actually does the collecting)
    def initialize(name, opts = {}, &block)
      unless opts[:xml_name]
        opts[:xml_name] = name.to_s.singularize.camelize.uncapitalize
      end
      if opts[:ref] && block_given?
        raise "Provide only one of :ref or a block"
      end
      super(name, opts)
      if opts[:ref]
        @struct = Ref.new(name, :class=> opts[:ref])
      else
        @struct = Struct.new(name, opts, &block)
      end
    end

    def from_xml(xml, model)
      model[name] = (xml[xml_name] || []).map { |elt| @struct.convert_from_xml(elt) }
    end

    def from_json(json, model)
      model[name] = (json[json_name] || []).map { |elt| @struct.convert_from_json(elt) }
    end

    def to_xml(model, xml)
      ary = (model[name] || []).map { |elt| @struct.convert_to_xml(elt) }
      xml[xml_name] = ary unless ary.empty?
    end

    def to_json(model, json)
      ary = (model[name] || []).map { |elt| @struct.convert_to_json(elt) }
      json[json_name] = ary unless ary.empty?
    end
  end

  class Hash < Attribute

    def initialize(name, opts = {}, &block)
      opts[:json_name] = name.to_s.pluralize unless opts[:json_name]
      super(name, opts)
    end

    def from_xml(xml, model)
      model[name] = (xml[xml_name] || []).inject({}) do |result, item|
        result[item["key"]] = item["content"]
        result
      end
    end

    def from_json(json, model)
      model[name] = json[json_name] || {}
    end

    def to_xml(model, xml)
      ary = (model[name] || {}).map { |k, v| { "key" => k, "content" => v } }
      xml[xml_name] = ary unless ary.empty?
    end

    def to_json(model, json)
      if model[name] && ! model[name].empty?
        json[json_name] = model[name]
      end
    end
  end

  class Collection < Attribute
    def initialize(name, opts = {})
      params = {}
      params[:scope] = opts.delete(:scope)
      super(name, opts)
      unless opts[:class]
        raise "Specify the class of collection entries using :class"
      end
      params[:embedded] = true
      unless opts[:class].collection_class
        opts[:class].collection_class = CIMI::Model::Collection.generate(opts[:class], params)
      end
      @collection_class = opts[:class].collection_class
    end

    def from_xml(xml, model)
      if xml[xml_name]
        model[name] = @collection_class.schema.from_xml(xml[xml_name].first, {})
      end
    end

    def from_json(json, model)
      if json[json_name]
        model[name] = @collection_class.schema.from_json(json[json_name], {})
      end
    end

    def to_xml(model, xml)
      return if model[name].nil?
      model[name].prepare
      if model[name].entries.empty?
        xml[xml_name] = { "href" => model[name].href }
      else
        xml[xml_name] = @collection_class.schema.to_xml(model[name])
      end
    end

    def to_json(model, json)
      return if model[name].nil?
      model[name].prepare
      if model[name].entries.empty?
        json[json_name] = { "href" => model[name].href }
      else
        json[json_name] = @collection_class.schema.to_json(model[name])
      end
    end

    # Convert a Hash or Array to an instance of the collection class
    def convert(value)
      if value.is_a?(::Array)
        @collection_class.new(:entries => value)
      else
        @collection_class.new(value || {})
      end
    end
  end

  #
  # The actual Schema class
  #

  attr_accessor :attributes

  def initialize
    @attributes = []
  end

  def deep_clone
    Marshal::load(Marshal.dump(self))
  end

  def collections
    @attributes.select { |a| a.is_a?(Collection) }
  end

  def convert(name, value)
    attr = @attributes.find { |a| a.name == name }
    raise "Unknown attribute #{name}" unless attr
    attr.convert(value)
  end

  def from_xml(xml, model = {})
    @attributes.freeze
    @attributes.each { |attr| attr.from_xml(xml, model) }
    model
  end

  def from_json(json, model = {})
    @attributes.freeze
    @attributes.each { |attr| attr.from_json(json, model) }
    model
  end

  def to_xml(model, xml = nil)
    xml ||= OrderedHash.new
    @attributes.freeze
    model.prepare if model.respond_to?(:prepare)
    @attributes.each { |attr| attr.to_xml(model, xml) }
    xml
  end

  #For MachineCollection, copy over the schema of Machine to hold
  #each member of the collection - avoid duplicating the schemas
  def add_collection_member_array(model)
    member_symbol = model.name.split("::").last.underscore.pluralize.to_sym
    members = CIMI::Model::Schema::Array.new(member_symbol)
    members.struct.schema.attributes = model.schema.attributes
    self.attributes << members
  end

  def to_json(model, json = {})
    @attributes.freeze
    model.prepare if model.respond_to?(:prepare)
    @attributes.each { |attr| attr.to_json(model, json) }
    json
  end

  def attribute_names
    @attributes.map { |a| a.name }
  end

  def required_attributes
    @attributes.select { |a| a.required? }
  end

  #
  # The DSL
  #
  # Requires that the class into which this is included has a
  # +add_attributes!+ method
  module DSL

    def resource_attr(name, opts={})
      CIMI::Model::ResourceMetadata.add_resource_attribute!(self, name, opts)
      if opts[:type]
        send(opts[:type], name)
      else
        text name
      end
    end

    def href(*args)
      opts = args.extract_opts!
      args.each { |arg| struct(arg, opts) { scalar :href, :required => opts[:required] } }
    end

    def text(*args)
      args.expand_opts!(:text => :nested)
      scalar(*args)
    end

    def scalar(*args)
      add_attributes!(args, Scalar)
    end

    def array(name, opts={}, &block)
      add_attributes!([name, opts], Array, &block)
    end

    def struct(name, opts={}, &block)
      add_attributes!([name, opts], Struct, &block)
    end

    def ref(name, opts={})
      unless opts[:class]
        s = name.to_s.camelize.gsub(/Config$/, "Configuration")
        opts[:class] = CIMI::Model::const_get(s)
      end
      add_attributes!([name, opts], Ref)
    end

    def hash_map(name)
      add_attributes!([name, {}], Hash)
    end

    def collection(name, opts={})
      opts[:scope] = self
      add_attributes!([name, opts], Collection)
    end
  end

  include DSL

  def add_attributes!(args, attr_klass, &block)
    raise "The schema has already been used to convert objects" if @attributes.frozen?
    opts = args.extract_opts!
    args.each { |arg| @attributes << attr_klass.new(arg, opts, &block) }
  end
end
