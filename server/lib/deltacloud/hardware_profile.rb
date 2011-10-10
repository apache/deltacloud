#
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
  class HardwareProfile

    UNITS = {
      :memory => "MB",
      :storage => "GB",
      :architecture => "label",
      :cpu => "count"
    }

    def self.unit(name)
      UNITS[name]
    end

    class Property
      attr_reader :name, :kind, :default
      # kind == :range
      attr_reader :first, :last
      # kind == :enum
      attr_reader :values
      # kind == :fixed
      attr_reader :value

      def initialize(name, values, opts = {})
        @name = name
        if values.is_a?(Range)
          @kind = :range
          @first = values.first
          @last = values.last
          @default = values.first
        elsif values.is_a?(Array)
          @kind = :enum
          @values = values
          @default = values.first
        else
          @kind = :fixed
          @value = values
          @default = @value
        end
        @default = opts[:default] if opts[:default]
      end

      def unit
        HardwareProfile.unit(name)
      end

      def param
        :"hwp_#{name}"
      end

      def fixed?
        kind == :fixed
      end

      def valid?(v)
        case kind
          when :fixed then (v == @default.to_s)
          when [:range, :enum] then (value.include?(v.to_i))
          else false
        end
      end

      def to_param
        Validation::Param.new([param, :string, :optional, []])
      end

      def include?(v)
        if kind == :fixed
          return v == value
        else
          return values.include?(v)
        end
      end
    end

    class << self
      def property(prop)
        define_method(prop) do |*args|
          values, opts, *ignored = *args
          instvar = :"@#{prop}"
          unless values.nil?
            @properties[prop] = Property.new(prop, values, opts || {})
          end
          @properties[prop]
        end
      end
    end

    attr_reader :name
    property :cpu
    property :architecture
    property :memory
    property :storage

    def initialize(name,&block)
      @properties   = {}
      @name         = name
      instance_eval &block if block_given?
    end

    def each_property(&block)
      @properties.each_value { |prop| yield prop }
    end

    def properties
      @properties.values
    end

    def property(name)
      @properties[name.to_sym]
    end

    def default?(prop, v)
      p = @properties[prop.to_sym]
      p && p.default.to_s == v
    end

    def to_hash
      props = []
      self.each_property do |p|
        if p.kind.eql? :fixed
          props << { :kind => p.kind, :value => p.value, :name => p.name, :unit => p.unit }
        else
          param = { :operation => "create", :method => "post", :name => p.name }
          if p.kind.eql? :range
            param[:range] = { :first => p.first, :last => p.last }
          elsif p.kind.eql? :enum
            param[:enum] = p.values.collect { |v| { :entry => v } }
          end
          param
          props << { :kind => p.kind, :value => p.default, :name => p.name, :unit => p.unit, :param => param }
        end
      end
      {
        :id => self.name,
        :properties => props
      }
    end

    def include?(prop, v)
      p = @properties[prop]
      p.nil? || p.include?(v)
    end

    def params
      @properties.values.inject([]) { |m, prop|
        m << prop.to_param
      }.compact
    end
  end
end
