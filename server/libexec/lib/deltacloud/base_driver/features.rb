require 'deltacloud/validation'

# Add advertising of optional features to the base driver
module Deltacloud

  class FeatureError < StandardError; end
  class DuplicateFeatureDeclError < FeatureError; end
  class DuplicateFeatureError < FeatureError; end
  class UndeclaredFeatureError < FeatureError; end

  class BaseDriver

    # An operation on a collection like cretae or show. Features
    # can add parameters to operations
    class Operation
      attr_reader :name

      include Deltacloud::Validation

      def initialize(name, &block)
        @name = name
        @params = {}
        instance_eval &block
      end
    end

    # The declaration of a feature, defines what operations
    # are modified by it
    class FeatureDecl
      attr_reader :name, :operations

      def initialize(name, &block)
        @name = name
        @operations = []
        instance_eval &block
      end

      def description(text=nil)
        @description = text if text
        @description
      end

      def operation(name, &block)
        @operations << Operation.new(name, &block)
      end
    end

    # A specific feature enabled by a driver (see +feature+)
    class Feature
      attr_reader :decl

      def initialize(decl, &block)
        @decl = decl
        instance_eval &block if block_given?
      end

      def name
        decl.name
      end

      def operations
        decl.operations
      end

      def description
        decl.description
      end
    end

    def self.feature_decls
      @@feature_decls ||= {}
    end

    def self.feature_decl_for(collection, name)
      decls = feature_decls[collection]
      if decls
        decls.find { |dcl| dcl.name == name }
      else
        nil
      end
    end

    # Declare a new feature
    def self.declare_feature(collection, name, &block)
      feature_decls[collection] ||= []
      raise DuplicateFeatureDeclError if feature_decl_for(collection, name)
      feature_decls[collection] << FeatureDecl.new(name, &block)
    end

    def self.features
      @@features ||= {}
    end

    # Declare in a driver that it supports a specific feature
    def self.feature(collection, name, &block)
      features[collection] ||= []
      if features[collection].find { |f| f.name == name }
        raise DuplicateFeatureError
      end
      unless decl = feature_decl_for(collection, name)
        raise UndeclaredFeatureError, "No feature #{name} for #{collection}"
      end
      features[collection] << Feature.new(decl, &block)
    end

    def features(collection)
      self.class.features[collection] || []
    end

    #
    # Declaration of optional features
    #
  end
end
