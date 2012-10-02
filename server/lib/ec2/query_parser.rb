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

module Deltacloud::EC2

  class ActionHandler

    MAPPINGS = {
      :describe_availability_zones => { :method => :realms, :params => { 'ZoneName.1' => :id } },
      :describe_images => { :method => :images, :params => { 'ImageId.1' => :id }},
      :describe_instances => { :method => :instances, :params => {} },
      :describe_key_pairs => { :method => :keys, :params => {} },
      :create_key_pair => { :method => :create_key, :params => { 'KeyName' => :key_name }},
      :delete_key_pair => { :method => :destroy_key, :params => { 'KeyName' => :id }},
      :run_instances => { :method => :create_instance, :params => { 'ImageId' => :image_id, 'InstanceType' => :hwp_id, 'Placement.AvailabilityZone' => :realm_id }},
      :stop_instances => { :method => :stop_instance, :params => { 'InstanceId.1' => :id }},
      :start_instances => { :method => :start_instance, :params => { 'InstanceId.1' => :id }},
      :reboot_instances => { :method => :reboot_instance, :params => { 'InstanceId.1' => :id }},
      :terminate_instances => { :method => :destroy_instance, :params => { 'InstanceId.1' => :id }},
    }

    def self.mappings
      MAPPINGS
    end

    attr_reader :action

    def initialize(action)
      @action = action
    end

    def deltacloud_method
      self.class.mappings[action.action][:method]
    end

    def deltacloud_method_params
      parameters = action.parameters.dup
      self.class.mappings[action.action][:params].inject({}) do |result, p|
        result[p.last] = parameters.delete(p.first)
        result.delete_if { |k,v| v.nil? }
      end
    end

    def perform!(credentials, driver)
      @result = case deltacloud_method
        when :create_instance then driver.send(deltacloud_method, credentials, deltacloud_method_params.delete(:image_id), deltacloud_method_params)
        when :stop_instance then instance_action(driver, deltacloud_method, credentials, deltacloud_method_params.delete(:id))
        when :start_instance then instance_action(driver, deltacloud_method, credentials, deltacloud_method_params.delete(:id))
        when :destroy_instance then driver.send(deltacloud_method, credentials, deltacloud_method_params.delete(:id))
        when :reboot_instance then driver.send(deltacloud_method, credentials, deltacloud_method_params.delete(:id))
        else driver.send(deltacloud_method, credentials, deltacloud_method_params)
      end
    end

    # Some drivers, like RHEV-M does not return the instance object
    # but just notify client that the action was executed successfully.
    #
    # If we not received an Instance object, then we need to do additional
    # query.
    #
    def instance_action(driver, action, credentials, id)
      instance = driver.send(action, credentials, id)
      if instance.kind_of? Instance
        instance
      else
        driver.instance(credentials, :id => id)
      end
    end

    def to_xml(context)
      ResultParser.parse(action, @result, context)
    end

  end

  class ResultParser

    include ResultHelper

    attr_reader :query
    attr_reader :object
    attr_reader :context

    def self.parse(query, result, context)
      parser = new(query, result, context)
      layout = "%#{query.action.to_s.camelize}Response{:xmlns => 'http://ec2.amazonaws.com/doc/2012-04-01/'}\n"+
        "\t%requestId #{query.request_id}\n" +
        "\t=render(:#{query.action}, object)\n"
      Haml::Engine.new(layout, :filename => 'layout').render(parser)
    end

    def initialize(query, object, context)
      @context = context
      @query = query
      @object = object
    end

    def build_xml
      Converter.convert(query.action, object)
    end

    def render(template, obj)
      template_filename = File.join(File.dirname(__FILE__), 'views', '%s.haml' % template.to_s)
      Haml::Engine.new(File.read(template_filename), :filename => template_filename).render(self, :object => obj)
    end

  end

  class QueryParser

    class InvalidAction < StandardError; end

    def self.parse(params, request_id)
      parser = new(request_id, params)
      unless parser.valid_action?
        raise InvalidAction.new('Invalid action (%s)' % parser.action)
      else
        ActionHandler.new(parser)
      end
    end

    attr_reader :action
    attr_reader :parameters
    attr_reader :version
    attr_reader :expiration
    attr_reader :authentication
    attr_reader :request_id

    def initialize(request_id, params={})
      @request_id = request_id
      @action = (params.delete('Action') || 'Unknown').underscore.intern
      @version = params.delete('Version')
      @authentication = {
        :security_token => params.delete('SecurityToken'),
        :access_key_id => params.delete('AWSAccessKeyId'),
        :signature => {
          :version => params.delete('SignatureVersion'),
          :value => params.delete('Signature'),
          :method => params.delete('SignatureMethod'),
          :timestamp => params.delete('Timestamp')
        }
      }
      @expiration = params.delete('Expires')
      @parameters = params
    end

    def valid_actions
      ActionHandler::mappings.keys
    end

    def valid_action?
      return false if @action == :unknown
      return false unless valid_actions.include?(@action)
      true
    end


  end

end
