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

# The smarts of converting from XML and JSON into internal objects
class CIMI::Model::Schema

  #
  # Attributes describe how we extract values from XML/JSON
  #
  class Attribute
    attr_reader :name, :xml_name, :json_name

    def initialize(name, opts = {})
      @name = name
      @xml_name = (opts[:xml_name] || name).to_s.camelize(true)
      @json_name = (opts[:json_name] || name).to_s.camelize(true)
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
      json[@json_name] = model[@name] if model[@name]
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
        when :nested : model[@name] = xml[@xml_name].first["content"] if xml[@xml_name]
        when :direct : model[@name] = xml["content"]
        else model[@name] = xml[@xml_name]
      end
    end

    def to_xml(model, xml)
      return unless model[@name]
      case @text
        when :nested : xml[@xml_name] = [{ "content" => model[@name] }]
        when :direct : xml["content"] = model[@name]
        else xml[@xml_name] = model[@name]
      end
    end
  end

  class Struct < Attribute
    def initialize(name, opts, &block)
      content = opts[:content]
      super(name, opts)
      @schema = CIMI::Model::Schema.new
      @schema.instance_eval(&block) if block_given?
      @schema.scalar(content, :text => :direct) if content
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
      xml = {}
      @schema.to_xml(model, xml)
      xml
    end

    def convert_to_json(model)
      json = {}
      @schema.to_json(model, json)
      json
    end

    private
    def struct
      cname = "CIMI_#{json_name.upcase_first}"
      if ::Struct.const_defined?(cname)
        ::Struct.const_get(cname)
      else
        ::Struct.new("CIMI_#{json_name.upcase_first}",
                     *@schema.attribute_names)
      end
    end
  end

  class Array < Attribute
    # For an array :things, we collect all <thing/> elements (XmlSimple
    # actually does the collecting)
    def initialize(name, opts = {}, &block)
      opts[:xml_name] = name.to_s.singularize unless opts[:xml_name]
      super(name, opts)
      @struct = Struct.new(name, opts, &block)
    end

    def from_xml(xml, model)
      model[name] = (xml[xml_name] || []).map { |elt| @struct.convert_from_xml(elt) }
    end

    def from_json(json, model)
      model[name] = (json[json_name] || []).map { |elt| @struct.convert_from_json(elt) }
    end

    def to_xml(model, xml)
      ary = model[name].map { |elt| @struct.convert_to_xml(elt) }
      xml[xml_name] = ary unless ary.empty?
    end

    def to_json(model, json)
      ary = model[name].map { |elt| @struct.convert_to_json(elt) }
      json[json_name] = ary unless ary.empty?
    end
  end

  #
  # The actual Schema class
  #
  def initialize
    @attributes = []
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

  def to_xml(model, xml = {})
    @attributes.freeze
    @attributes.each { |attr| attr.to_xml(model, xml) }
    xml
  end

  def to_json(model, json = {})
    @attributes.freeze
    @attributes.each { |attr| attr.to_json(model, json) }
    json
  end

  def attribute_names
    @attributes.map { |a| a.name }
  end

  #
  # The DSL
  #
  # Requires that the class into which this is included has a
  # +add_attributes!+ method
  module DSL
    def href(*args)
      args.each { |arg| struct(arg) { scalar :href } }
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
  end

  include DSL

  def add_attributes!(args, attr_klass, &block)
    raise "The schema has already been used to convert objects" if @attributes.frozen?
    opts = args.extract_opts!
    args.each { |arg| @attributes << attr_klass.new(arg, opts, &block) }
  end
end
