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
      :run_instances => { :method => :create_instance, :params => { 'ImageId' => :image_id, 'InstanceType' => :hwp_id, 'Placement.AvailabilityZone' => :realm_id }}
    }

    attr_reader :action

    def initialize(action)
      @action = action
    end

    def deltacloud_method
      MAPPINGS[action.action][:method]
    end

    def deltacloud_method_params
      MAPPINGS[action.action][:params].inject({}) do |result, p|
        result[p.last] = action.parameters.delete(p.first)
        result.delete_if { |k,v| v.nil? }
      end
    end

    def perform!(credentials, driver)
      @result = case deltacloud_method
        when :create_instance then driver.send(deltacloud_method, credentials, deltacloud_method_params.delete(:image_id), deltacloud_method_params)
        else driver.send(deltacloud_method, credentials, deltacloud_method_params)
      end
    end

    def to_xml
      ResultParser.parse(action, @result).to_xml
    end

  end

  class ResultParser

    def self.parse(parser, result)
      Nokogiri::XML::Builder.new do |xml|
        xml.send(:"#{parser.action.to_s.camelize}Response", :xmlns => 'http://ec2.amazonaws.com/doc/2012-04-01/') {
          xml.requestId parser.request_id
          new(xml, parser, result).build_xml
        }
      end
    end

    def initialize(xml, parser, result)
      @builder = xml
      @parser = parser
      @result = result
    end

    def build_xml
      Converter.convert(@builder, @parser.action, @result)
    end

  end

  class QueryParser

    def self.parse(params, request_id)
      parser = new(request_id, params)
      unless parser.valid_action?
        raise 'Invalid action (%s)' % parser.action
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
      ActionHandler::MAPPINGS.keys
    end

    def valid_action?
      return false if @action == :unknown
      return false unless valid_actions.include?(@action)
      true
    end


  end

end
