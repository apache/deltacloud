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
    } unless defined?(UNITS)

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
        v = convert_property_value_type(v)
        case kind
          # NOTE:
          # Currently we cannot validate fixed values because of UI
          # limitation. In UI we have multiple hwp_* properties which overide
          # each other.
          # Then provider have one 'static' hardware profile and one
          # 'customizable' when user select the static one the UI also send
          # values from the customizable one (which will lead to a validation
          # error because validation algorith will think that client want to
          # overide fixed values.
          #
          # when :fixed then (v == @default.to_s)
          when :fixed then true
          when :range then match_type?(first, v) and (first..last).include?(v)
          when :enum then match_type?(values.first, v) and values.include?(v)
          else false
        end
      end

      def to_param
        if defined? Sinatra::Rabbit
          Sinatra::Rabbit::Param.new([param, :string, :optional, []])
        end
      end

      def include?(v)
        if kind == :fixed
          return v == value
        else
          return values.include?(v)
        end
      end

      private

      def match_type?(reference, value)
        true if reference.class == value.class
      end

      def convert_property_value_type(v)
        return v.to_f if v =~ /(\d+)\.(\d+)/
        return v.to_i if v =~ /(\d+)/
        v.to_s
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
      property(prop) && property(prop).default.to_s == v
    end

    def include?(prop, v)
      return false unless p = property(prop)
      return true if p.kind == :range and (p.first..p.last).include?(v)
      return true if p.kind == :enum and p.values.include?(v)
      false
    end

    def params
      @properties.values.inject([]) { |m, prop|
        m << prop.to_param
      }.compact
    end
  end
end
