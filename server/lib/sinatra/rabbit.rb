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

require 'sinatra/base'
require 'sinatra/url_for'
require 'deltacloud/validation'
require 'deltacloud/backend_capability'

module Sinatra

  module Rabbit

    def self.routes
      @routes ||= []
    end

    class DuplicateParamException < Deltacloud::ExceptionHandler::DeltacloudException; end
    class DuplicateOperationException < Deltacloud::ExceptionHandler::DeltacloudException; end
    class DuplicateCollectionException < Deltacloud::ExceptionHandler::DeltacloudException; end
    class UnsupportedCollectionException < Deltacloud::ExceptionHandler::DeltacloudException
      def initialize
        # The server understood the request, but is refusing to fulfill it. Authorization will not help and the request
        # SHOULD NOT be repeated. If the request method was not HEAD and the server wishes to make public why the request
        # has not been fulfilled, it SHOULD describe the reason for the refusal in the entity. If the server does not wish
        # to make this information available to the client, the status code 404 (Not Found) can be used instead.
        super(403, 'UnsupportedCollection', "Requested collection is not supported for current provider", [])
      end
    end

    class Operation
      attr_reader :name, :method, :collection, :member

      include ::Deltacloud::BackendCapability
      include ::Deltacloud::Validation
      include ::ApplicationHelper

      STANDARD = {
        :new => { :method => :get, :member => false, :form => true },
        :index => { :method => :get, :member => false },
        :show =>  { :method => :get, :member => true },
        :create => { :method => :post, :member => false },
        :update => { :method => :put, :member => true },
        :destroy => { :method => :delete, :member => true }
      }

      def initialize(coll, name, opts, &block)
        @name = name.to_sym
        opts = STANDARD[@name].merge(opts) if standard?
        @path_generator = opts[:path_generator]
        @collection, @standard = coll, opts[:standard]
        raise "No method for operation #{name}" unless opts[:method]
        @method = opts[:method].to_sym
        @member = opts[:member]
        @description = ""
        instance_eval(&block) if block_given?
        generate_documentation
        generate_options
      end

      def http_method
        @method
      end

      def standard?
        STANDARD.keys.include?(name) || @standard
      end

      def form?
        STANDARD[name] and STANDARD[name][:form]
      end

      def description(text="")
        return @description if text.blank?
        @description = text
      end

      def generate_documentation
        coll, oper = @collection, self
        Rabbit::routes << [:get, "#{settings.root_url}/docs/#{@collection.name}/#{@name}"]
        ::Sinatra::Application.get("#{settings.root_url}/docs/#{@collection.name}/#{@name}") do
          @collection, @operation = coll, oper
          @features = driver.features_for_operation(coll.name, oper.name)
          respond_to do |format|
            format.html { haml :'docs/operation' }
            format.xml { haml :'docs/operation' }
          end
        end
      end

      def generate_options
        current_operation = self
        Rabbit::routes << [:options, "#{settings.root_url}/#{current_operation.collection.name}/#{current_operation.name}"]
        ::Sinatra::Application.options("#{settings.root_url}/#{current_operation.collection.name}/#{current_operation.name}") do
          required_params = current_operation.effective_params(driver).collect do |name, validation|
            name.to_s if validation.type.eql?(:required)
          end.compact.join(',')
          optional_params = current_operation.effective_params(driver).collect do |name, validation|
            name.to_s if validation.type.eql?(:optional)
          end.compact.join(',')
          headers 'X-Required-Parameters' => required_params
          headers 'X-Optional-Parameters' => optional_params
          [200, '']
        end
      end

      def control(&block)
        op = self
        @control = Proc.new do
          op.collection.check_supported(driver)
          op.check_capability(driver)
          op.validate(driver, op.effective_params(driver), params, credentials)
          instance_eval(&block)
        end
      end

      def member?
        if standard?
          @member || STANDARD[name][:member]
        else
          @member
        end
      end

      def path(args = {})
        return @path_generator.call(self) if @path_generator
        if member?
          if standard?
            "#{@collection.name}/:id"
          else
            "#{@collection.name}/:id/#{name}"
          end
        else
          if form?
            "#{@collection.name}/#{name}"
          else
            "#{@collection.name}"
          end
        end
      end

      def generate
        Rabbit::routes << [@method, "#{settings.root_url}/#{path}"]
        ::Sinatra::Application.send(@method, "#{settings.root_url}/#{path}", {}, &@control)
        # Set up some Rails-like URL helpers
        if name == :index
          gen_route "#{@collection.name}_url"
        elsif name == :show
          gen_route "#{@collection.name.to_s.singularize}_url"
        else
          gen_route "#{name}_#{@collection.name.to_s.singularize}_url"
        end
      end

      # Return a hash of all params, the params statically defined for this
      # operation plus the params defined by any features in the +driver+
      # that might modify this operation
      def effective_params(driver)
        driver.features(@collection.name).collect do |f|
          f.decl.operation(@name)
        end.flatten.select { |op| op }.inject(params.dup) do |result, fop|
          fop.params.each_key do |k|
            if result.has_key?(k)
              raise DuplicateParamException, "Parameter '#{k}' for operation #{fop.name} in collection #{@collection.name}"
            else
              result[k] = fop.params[k]
            end
          end
          result
        end
      end

      private
      def gen_route(name)
        route_url = path
        if @member
          ::Sinatra::Application.send(:define_method, name) do |id, *args|
            url = query_url(route_url, args[0])
            api_url_for url.gsub(/:id/, id.to_s), :full
          end
        else
          ::Sinatra::Application.send(:define_method, name) do |*args|
            url = query_url(route_url, args[0])
            api_url_for url, :full
          end
        end
      end
    end

    class Collection
      attr_reader :name, :operations, :subcollections

      def initialize(name, options={}, &block)
        @name = name
        @description = ""
        @operations, @subcollections = {}, {}
        @global = options[:global] || false
        instance_eval(&block) if block_given?
        generate_documentation
        generate_head
        generate_options
      end

      def subcollection?
        self.class == SubCollection
      end

      # Set/Return description for collection
      # If first parameter is not present, full description will be
      # returned.
      def description(text='')
        return @description if text.blank?
        @description = text
      end

      # Mark this collection as global, i.e. independent of any specific
      # driver
      def global!
        @global = true
      end

      # Return +true+ if this collection is global, i.e. independent of any
      # specific driver
      def global?
        @global
      end

      def generate_head
        current_collection = self
        Rabbit::routes << [:head, "#{settings.root_url}/#{name}"]
        ::Sinatra::Application.head("#{settings.root_url}/#{name}") do
          methods_allowed = current_collection.operations.collect { |o| o[1].method.to_s.upcase }.uniq.join(',')
          headers 'Allow' => "HEAD,OPTIONS,#{methods_allowed}"
          [200, '']
        end
      end

      def generate_options
        current_collection = self
        Rabbit::routes << [:options, "#{settings.root_url}/#{name}"]
        ::Sinatra::Application.options("#{settings.root_url}/#{name}") do
          operations_allowed = current_collection.operations.collect { |o| o[0] }.join(',')
          headers 'X-Operations-Allowed' => operations_allowed
          [200, '']
        end
      end

      def generate_documentation
        coll = self
        Rabbit::routes << [:get, "#{settings.root_url}/docs/#{@name}"]
        ::Sinatra::Application.get("#{settings.root_url}/docs/#{@name}") do
          coll.check_supported(driver)
          @collection = coll
          @operations = coll.operations
          @features = driver.features(coll.name)
          respond_to do |format|
            format.html { haml :'docs/collection' }
            format.xml { haml :'docs/collection' }
          end
        end
      end

      # Add a new operation for this collection. For the standard REST
      # operations :index, :show, :update, and :destroy, we already know
      # what method to use and whether this is an operation on the URL for
      # individual elements or for the whole collection.
      #
      # For non-standard operations, options must be passed:
      #  :method : one of the HTTP methods
      #  :member : whether this is an operation on the collection or an
      #            individual element (FIXME: custom operations on the
      #            collection will use a nonsensical URL) The URL for the
      #            operation is the element URL with the name of the operation
      #            appended
      #
      # This also defines a helper method like show_instance_url that returns
      # the URL to this operation (in request context)
      def operation(name, opts = {}, &block)
        if @operations.keys.include?(name)
          raise DuplicateOperationException::new(500, "DuplicateOperation", "Operation #{name} is already defined", [])
        end
        @operations[name] = Operation.new(self, name, opts, &block)
      end

      def collection(name, opts={}, &block)
        if subcollections.keys.include?(name)
          raise DuplicateOperationException::new(500, "DuplicateSubcollection", "Subcollection #{name} is already defined", [])
        end
        subcollections[name] = SubCollection.new(self, name, opts, &block)
        subcollections[name].generate
      end

      def generate
        operations.values.reject { |op| op.member }.each { |o| o.generate }
        operations.values.select { |op| op.member }.each { |o| o.generate }
        app = ::Sinatra::Application
        collname = name # Work around Ruby's weird scoping/capture
        app.send(:define_method, "#{name.to_s.singularize}_url") do |id|
          api_url_for "#{collname}/#{id}", :full
        end
        if index_op = operations[:index]
          app.send(:define_method, "#{name}_url") do
            api_url_for index_op.path.gsub(/\/\?$/,''), :full
          end
        end
      end

      def check_supported(driver)
        unless global? || driver.has_collection?(@name) || self.kind_of?(Sinatra::Rabbit::SubCollection)
          raise UnsupportedCollectionException
        end
      end
    end

    class SubCollection < Collection

      attr_accessor :parent

      def initialize(parent, name, opts={}, &block)
        self.parent = parent
        super(name, &block)
      end

      def operation(name, opts = {}, &block)
        if @operations.keys.include?(name)
          raise DuplicateOperationException::new(500, "DuplicateOperation", "Operation #{name} is already defined", [])
        end
        # Preserve self as local variable to workaround Ruby namespace
        # weirdness
        c = self
        path_generator = Proc.new do |obj|
          if obj.member?
            if obj.standard?
              "#{parent.name}/:#{parent.name.to_s.singularize}/:#{c.name.to_s.singularize}"
            else
              "#{parent.name}/:#{parent.name.to_s.singularize}/:#{c.name.to_s.singularize}/#{name}"
            end
          else
            if obj.form?
              "#{parent.name}/:id/:#{parent.name.to_s.singularize}/#{obj.name}"
            else
              "#{parent.name}/:#{parent.name.to_s.singularize}"
            end
          end
        end
        opts.merge!({
          :path_generator => path_generator
        })
        @operations[name] = Operation.new(self, name, opts, &block)
      end

      def generate
        operations.values.reject { |op| op.member }.each { |o| o.generate }
        operations.values.select { |op| op.member }.each { |o| o.generate }
        app = ::Sinatra::Application
        collname = name # Work around Ruby's weird scoping/capture
        app.send(:define_method, "#{parent.name.to_s}_#{name.to_s.singularize}_url") do |id, subid|
          api_url_for "#{collname}/#{id}/#{subid}", :full
        end
        if index_op = operations[:index]
          app.send(:define_method, "#{parent.name.to_s}_#{name}_url") do
            api_url_for index_op.path.gsub(/\/\?$/,''), :full
          end
        end
      end

    end

    def collections
      @collections ||= {}
    end

    # Create a new collection. NAME should be the pluralized name of the
    # collection.
    #
    # Adds a helper method #{name}_url which returns the URL to the :index
    # operation on this collection.
    def collection(name, &block)
      raise DuplicateCollectionException if collections[name]
      collections[name] = Collection.new(name, &block)
      collections[name].generate
    end

    def global_collection(name, &block)
      raise DuplicateCollectionException if collections[name]
      collections[name] = Collection.new(name, { :global => true }, &block)
      collections[name].generate
    end

    # Make sure this collection can be accessed, regardless of whether the
    # driver supports it or not
    def global_collection(name, &block)
      raise DuplicateCollectionException if collections[name]
      collections[name] = Collection.new(name, :global => true, &block)
      collections[name].generate
    end
  end

  module RabbitHelper
    def query_url(url, params)
      return url if params.nil? || params.empty?
      url + "?#{URI.escape(params.collect{|k,v| "#{k}=#{v}"}.join('&'))}"
    end

    def entry_points
      collections.values.select { |coll|
        coll.global? || driver.has_collection?(coll.name)
      }.inject([]) do |m, coll|
        url = api_url_for coll.operations[:index].path, :full
        m << [ coll.name, url ]
      end
    end
  end

  register Rabbit
  helpers RabbitHelper
end

# In Sinatra < 1.2 there was no helper to create OPTIONS route
unless Sinatra::Base.respond_to? :options
  configure do
    class << Sinatra::Base
      def options(path, opts={}, &block)
        route 'OPTIONS', path, opts, &block
      end
    end
    Sinatra::Delegator.delegate :options
  end
end
