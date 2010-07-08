
module Deltacloud
  class HardwareProfile

    class Property
      attr_reader :name, :kind
      # kind == :range
      attr_reader :first, :last
      # kind == :enum
      attr_reader :values
      # kind == :fixed
      attr_reader :value

      def initialize(name, values)
        @name = name
        if values.is_a?(Range)
          @kind = :range
          @first = values.first
          @last = values.last
        elsif values.is_a?(Array)
          @kind = :enum
          @values = values
        else
          @kind = :fixed
          @value = values
        end
      end
    end

    class << self
      def property(prop)
        define_method(prop) do |*args|
          values, *ignored = *args
          instvar = :"@#{prop}"
          unless values.nil?
            @properties[prop] = Property.new(prop, values)
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
  end
end
