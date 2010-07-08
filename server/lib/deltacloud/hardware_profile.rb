
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
        "hwp_#{name}"
      end

      def fixed?
        kind == :fixed
      end

      def to_param
        return nil if kind == :fixed
        if kind == :range
          # FIXME: We can't validate ranges currently
          args = [param, :string, :optional]
        else
          args = [param, :string, :optional, values.collect { |v| v.to_s} ]
        end
        Validation::Param.new(args)
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

    def params
      @properties.values.inject([]) { |m, prop|
        m << prop.to_param
      }.compact
    end
  end
end
