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
require 'json'

# The base class for any CIMI object that we either read from a request or
# write as a response. This class handles serializing/deserializing XML and
# JSON into a common form.
#
# == Defining the schema
#
# The conversion of XML and JSON into internal objects is based on a schema
# that is defined through a DSL:
#
#   class Machine < CIMI::Model::Base
#     text :status
#     href :meter
#     array :volumes do
#       scalar :href, :attachment_point, :protocol
#     end
#   end
#
# The DSL automatically takes care of converting identifiers from their
# underscored form to the camel-cased form used by CIMI. The above class
# can be used in the following way:
#
#   machine = Machine.from_xml(some_xml)
#   if machine.status == "UP"
#     ...
#   end
#   sda = machine.volumes.find { |v| v.attachment_point == "/dev/sda" }
#   handle_meter(machine.meter.href)
#
# The keywords for the DSL are
#   [scalar(names, ...)]
#     Define a scalar attribute; in JSON, this is represented as a string
#     property. In XML, this can be represented in a number of ways,
#     depending on whether the option :text is set:
#       * :text not set: attribute on the enclosing element
#       * :text == :direct: the text content of the enclosing element
#       * :text == :nested: the text content of an element +<name>...</name>+
#   [text(names)]
#     A shorthand for +scalar(names, :text => :nested)+, i.e., for
#     attributes that in XML are represented by their own tags
#   [href(name)]
#     A shorthand for +struct name { scalar :href }+; in JSON, this is
#     represented as +{ name: { "href": string } }+, and in XML as +<name
#     href="..."/>+
#   [struct(name, opts, &block)]
#     A structured subobject; the block defines the schema of the
#     subobject. The +:content+ option can be used to specify the attribute
#     that should receive the content of hte corresponding XML element
#   [array(name, opts, &block)]
#     An array of structured subobjects; the block defines the schema of
#     the subobjects.

module CIMI::Model

  def self.register_as_root_entity!(name)
    @root_entities ||= []
    @root_entities << name
    unless CIMI::Model::CloudEntryPoint.href_defined?(name)
      CIMI::Model::CloudEntryPoint.send(:href, name.underscore)
    end
  end

  def self.root_entities
    @root_entities || []
  end

end

class CIMI::Model::Base

  #
  # We keep the values of the attributes in a hash
  #
  attr_reader :attribute_values

  # Keep the list of all attributes in an array +attributes+; for each
  # attribute, we also define a getter and a setter to access/change the
  # value for that attribute
  class << self
    def base_schema
      @schema ||= CIMI::Model::Schema.new
    end

    def clone_base_schema
      @schema_duped = true
      @schema = Marshal::load(Marshal.dump(superclass.base_schema))
    end

    def base_schema_cloned?
      @schema_duped
    end

    private :'clone_base_schema', :'base_schema_cloned?'

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
        define_method(name) { @attribute_values[name] }
        define_method(:"#{name}=") { |newval| @attribute_values[name] = newval }
      end
    end

    # Return Array of links to current CIMI object
    def all_uri(context)
      self.all(context).map { |e| { :href => e.uri } }
    end
  end

  extend CIMI::Model::Schema::DSL

  def [](a)
    @attribute_values[a]
  end

  def []=(a, v)
    @attribute_values[a] = v
  end

  #
  # Factory methods
  #
  def initialize(values = {})
    @attribute_values = values
  end

  # Construct a new object from the XML representation +xml+
  def self.from_xml(text)
    xml = XmlSimple.xml_in(text, :force_content => true)
    model = self.new
    @schema.from_xml(xml, model)
    model
  end

  # Construct a new object
  def self.from_json(text)
    json = JSON::parse(text)
    model = self.new
    @schema.from_json(json, model)
    model
  end

  #
  # Serialize
  #

  def self.xml_tag_name
    self.name.split("::").last
  end

  def self.to_json(model)
    JSON::unparse(@schema.to_json(model))
  end

  def self.to_xml(model)
    xml = @schema.to_xml(model)
    xml["xmlns"] = "http://www.dmtf.org/cimi"
    XmlSimple.xml_out(xml, :root_name => xml_tag_name)
  end

  def to_json
    self.class.to_json(self)
  end

  def to_xml
    self.class.to_xml(self)
  end

  #
  # Common attributes for all resources
  #
  text :uri, :name, :description, :created

  # FIXME: this doesn't match with JSON
  hash :property, :content => :value do
    scalar :name
  end

  def self.act_as_root_entity(name=nil)
    if name
      name = name.to_s.camelize.pluralize
    else
      name = xml_tag_name.pluralize.uncapitalize
    end
    CIMI::Model.register_as_root_entity! name
  end

  def self.all(_self); find(:all, _self); end

  def filter_by(filter_opts)
    return self if filter_opts.nil?
    return filter_attributes(filter_opts.split(',').map{ |a| a.intern }) if filter_opts.include? ','
    case filter_opts
      when /^([\w\_]+)$/ then filter_attributes([$1.intern])
      when /^([\w\_]+)\[(\d+\-\d+)\]$/ then filter_by_arr_range($1.intern, $2)
      when /^([\w\_]+)\[(\d+)\]$/ then filter_by_arr_index($1.intern, $2)
      else self
    end
  end

  private

  def filter_attributes(attr_list)
    attrs = attr_list.inject({}) do |result, attr|
      result[attr] = self.send(attr) if self.respond_to?(attr)
      result
    end
    self.class.new(attrs)
  end

  def filter_by_arr_index(attr, filter)
    return self unless self.respond_to?(attr)
    self.class.new(attr => [self.send(attr)[filter.to_i]])
  end

  def filter_by_arr_range(attr, filter)
    return self unless self.respond_to?(attr)
    filter = filter.split('-').inject { |s,e| s.to_i..e.to_i }
    self.class.new(attr => self.send(attr)[filter])
  end
end
