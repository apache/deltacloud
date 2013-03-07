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

module Deltacloud::Client

  class Base

    extend Helpers::XmlHelper

    include Deltacloud::Client::Helpers::Model
    include Deltacloud::Client::Methods::Api

    # These attributes are common for all models
    #
    # - obj_id -> The :id of Deltacloud API model (eg. instance ID)
    #
    attr_reader :obj_id
    attr_reader :name
    attr_reader :description

    # The Base class that other models should inherit from
    # To initialize, you need to suply these mandatory params:
    #
    # - :_client -> Reference to Client instance
    # - :_id     -> The 'id' of resource. The '_' is there to avoid conflicts
    #
    def initialize(opts={})
      @options = opts
      @obj_id = @options.delete(:_id)
      # Do not allow to modify the object#base_id
      @obj_id.freeze
      @client = @options.delete(:_client)
      @original_body = @options.delete(:original_body)
      update_instance_variables!(@options)
    end

    alias_method :_id, :obj_id

    # Populate instance variables in model
    # This method could be also used to update the variables for already
    # initialized models. Look at +Instance#reload!+ method.
    #
    def update_instance_variables!(opts={})
      @options.merge!(opts)
      @options.each { |key, val| self.instance_variable_set("@#{key}", val) unless val.nil? }
      self
    end

    # Eye-candy representation of model, without ugly @client representation
    #
    def to_s
      "#<#{self.class.name}> #{@options.merge(:_id => @obj_id).inspect}"
    end

    # An internal reference to the current Deltacloud::Client::Connection
    # instance. Used for implementing the model methods
    #
    def client
      @client
    end

    # Shorthand for +client+.connection
    #
    # Return Faraday connection object.
    #
    def connection
      client.connection
    end

    # Return the cached version of Deltacloud API entrypoint
    #
    def entrypoint
      client.entrypoint
    end

    # Return the original XML body model was constructed from
    # This might help debugging broken XML
    #
    def original_body
      @original_body
    end

    # The model#id is the old way how to get the Deltacloud API resource
    # 'id'. However this collide with the Ruby Object#id.
    #
    def id
      warn '[DEPRECATION] `id` is deprecated because of possible conflict with Object#id. Use `_id` instead.'
      _id
    end

    class << self

      # Parse the XML response body from Deltacloud API
      # to +Hash+. Result is then used to create an instance of Deltacloud model
      #
      # NOTE: Children classes **must** implement this class method
      #
      def parse(client_ref, inst)
        warn "The self#parse method **must** be defined in #{self.class.name}"
        {}
      end

      # Convert the parsed +Hash+ from +parse+ method to instance of Deltacloud model
      #
      # - client_ref -> Reference to the Client instance
      # - obj -> Might be a Nokogiri::Element or Response
      #
      def convert(client_ref, obj)
        body = extract_xml_body(obj).to_xml.root
        attrs = parse(body)
        attrs.merge!({
          :_id => body['id'],
          :_client => client_ref,
          :name => body.text_at(:name),
          :description => body.text_at(:description)
        })
        validate_attrs!(attrs)
        new(attrs.merge(:original_body => obj))
      end

      # Convert response for the collection responses.
      #
      def from_collection(client_ref, response)
        response.body.to_xml.xpath('/*/*').map do |entity|
          convert(client_ref, entity)
        end
      end

      # The :_id and :_client attributes are mandotory
      # to construct a Base model object.
      #
      def validate_attrs!(attrs)
        raise error.new('The :_id must not be nil.') if attrs[:_id].nil?
        raise error.new('The :_client reference is missing.') if attrs[:_client].nil?
      end

    end
  end
end
