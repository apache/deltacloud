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
#     collection :meters
#     array :volumes do
#       scalar :href, :initial_location
#     end
#     ref :latest_snapshot, CIMI::Model::MachineImage
#   end
#
#   class SystemTemplate < CIMI::Model::Base
#     array component_descriptors do
#       text :name
#       ...
#     end
#     array :meter_templates, :ref => CIMI::Model::MeterTemplate
#   end
#
#
# The DSL automatically takes care of converting identifiers from their
# underscored form to the camel-cased form used by CIMI. The above class
# can be used in the following way:
#
#   machine = Machine.from_xml(some_xml)
#   if machine.status == "UP"
#     ...
#   end
#   sda = machine.volumes.find { |v| v.initial_location == "/dev/sda" }
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
#   [ref(name, [klass])]
#     A reference to another object, like the reference to the
#     MachineConfiguration in a MachineTemplate. If +klass+ is not given,
#     an attempt is made to infer the class of the target of the reference
#     from +name+
#   [struct(name, opts, &block)]
#     A structured subobject; the block defines the schema of the
#     subobject. The +:content+ option can be used to specify the attribute
#     that should receive the content of the corresponding XML element
#   [array(name, opts, &block)] An array of structured subobjects; the
#     block defines the schema of the subobjects. If the entries are
#     references to other resources, instead of passing a block, pass the
#     class of the target of the references with the +:ref+ option
#   [collection(name, opts)]
#     A collection of associated objects; use the +:class+ option to
#     specify the type of the collection entries

module CIMI::Model

  class ValidationError < StandardError

    def initialize(attr_list, format)
      @lst = attr_list
      super("Required attributes not set: #{name}")
    end

    # Report the ValidationError as HTTP 400 - Bad Request
    def code
      400
    end

    def name
      @lst.join(',')
    end

  end

  class Base < Resource

    # Extend the base model with the collection handling methods
    extend CIMI::Model::CollectionMethods

    # Include methods needed to handle the $select query parameter
    include CIMI::Helpers::SelectBaseMethods

    #
    # Common attributes for all resources
    #
    text :id, :name, :description, :created, :updated
    hash_map :property
  end
end
