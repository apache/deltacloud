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

require 'deltacloud/validation'

# Add advertising of optional features to the base driver
module Deltacloud

  class FeatureError < StandardError; end
  class DuplicateFeatureDeclError < FeatureError; end
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

      # Add/modify an operation or look up an existing one. If +block+ is
      # provided, create a new operation if none exists with name
      # +name+. Evaluate the +block+ against this instance. If no +block+
      # is provided, look up the operation with name +name+
      def operation(name, &block)
        op = @operations.find { |op| op.name == name }
        if block_given?
          if op.nil?
            op = Operation.new(name, &block)
            @operations << op
          else
            op.instance_eval(&block)
          end
        end
        op
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
      @features ||= {}
    end

    # Declare in a driver that it supports a specific feature
    #
    # The same feature can be declared multiple times in a driver, so that
    # it can be changed successively by passing in different blocks.
    def self.feature(collection, name, &block)
      features[collection] ||= []
      if f = features[collection].find { |f| f.name == name }
        f.instance_eval(&block) if block_given?
        return f
      end
      unless decl = feature_decl_for(collection, name)
        raise UndeclaredFeatureError, "No feature #{name} for #{collection}"
      end
      features[collection] << Feature.new(decl, &block)
    end

    def features(collection)
      self.class.features[collection] || []
    end

    def features_for_operation(collection, operation)
      features(collection).select do |f|
        f.operations.detect { |o| o.name == operation }
      end
    end

    #
    # Declaration of optional features
    #
    declare_feature :images,  :owner_id do
      description "Filter images using owner id"
      operation :index do
        param :owner_id,  :string,  :optional,  nil,  "Owner ID"
      end
    end

    declare_feature :instances, :user_name do
      description "Accept a user-defined name on instance creation"
      operation :create do
        param :name, :string, :optional, nil,
        "The user-defined name"
      end
    end

    declare_feature :instances, :user_data do
      description "Make user-defined data available on a special webserver"
      operation :create do
        param :user_data, :string, :optional, nil,
        "Base64 encoded user data will be published to internal webserver"
      end
    end

    declare_feature :instances, :user_files do
      description "Accept up to 5 files to be placed into the instance before launch."
      operation :create do
        1.upto(5) do |i|
          param :"path#{i}", :string, :optional, nil,
          "Path where to place the #{i.ordinalize} file, up to 255 characters"
          param :"content#{i}", :string, :optional, nil,
          "Contents for the #{i.ordinalize} file, up to 10 kB, Base64 encoded"
        end
      end
    end

    declare_feature :instances, :security_group do
      description "Put instance in one or more security groups on launch"
      operation :create do
        param :security_group, :array, :optional, nil,
        "Array of security group names"
      end
    end

    declare_feature :instances, :authentication_key do
      operation :create do
        param :keyname, :string,  :optional, nil
        "EC2 key authentification method"
      end
      operation :show do
      end
    end

    declare_feature :instances, :authentication_password do
      operation :create do
        param :password, :string, :optional
      end
    end

    declare_feature :instances, :hardware_profiles do
      description "Size instances according to changes to a hardware profile"
      # The parameters are filled in from the hardware profiles
    end

    declare_feature :buckets, :bucket_location do
      description "Take extra location parameter for Bucket creation (e.g. S3, 'eu' or 'us-west-1')"
      operation :create do
        param :location, :string, :optional
      end
    end

    declare_feature :instances, :register_to_load_balancer do
      description "Register instance to load balancer"
      operation :create do
        param :load_balancer_id, :string, :optional
      end
    end

    declare_feature :instances, :instance_count do
      description "Number of instances to be launch with at once"
      operation :create do
        param :instance_count,  :string,  :optional
      end
    end

    declare_feature :instances, :sandboxing do
      description "Allow lanuching sandbox images"
      operation :create do
        param :sandbox, :string,  :optional
      end
    end

  end
end
