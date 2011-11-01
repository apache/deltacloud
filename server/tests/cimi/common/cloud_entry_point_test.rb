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
#

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/common'
require 'nokogiri'

module CimiUnitTest
  class CloudEntryPointTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_it_redirect_client_to_entrypoint
      get_url '/cimi'
      last_response.status.should == 301
      last_response.header['Location'].should == 'http://example.org/cimi/cloudEntryPoint'
    end

    def test_it_return_valid_content_type
      get_url '/cimi/cloudEntryPoint'
      last_response.content_type.should == 'application/CIMI-CloudEntryPoint+xml;charset=utf-8'
    end

    def test_it_return_valid_xmlns
      get_url '/cimi/cloudEntryPoint'
      (last_xml_response/'CloudEntryPoint').first.namespace.href.should == CMWG_NAMESPACE
    end

    def test_it_return_valid_root_element
      get_url '/cimi/cloudEntryPoint'
      last_xml_response.root.name == "CloudEntryPoint"
    end

    def test_it_include_all_properties
      get_url '/cimi/cloudEntryPoint'
      properties = ['uri', 'name', 'description', 'created', 'volumes', 'machines', 'machineImages', 'machineConfigurations'].sort
      (last_xml_response/'CloudEntryPoint/*').collect { |p| p.name }.sort.should == properties
    end

    def test_collection_have_href_attributes
      get_url '/cimi/cloudEntryPoint'
      collections = [ 'volumes', 'machines', 'machineImages', 'machineConfigurations' ]
      (last_xml_response/'CloudEntryPoint/*').each do |collection|
        collection[:href].should_not nil
      end
    end

    def test_collection_href_attributes_are_valid
      valid_uris = {
        'volumes' => 'cimi/volumes',
        'machines' => 'cimi/machines',
        'machineImages' => 'cimi/machine_images',
        'machineConfiguration' => 'cimi/machine_configurations'
      }
      get_url '/cimi/cloudEntryPoint'
      (last_xml_response/'CloudEntryPoint/*').each do |collection|
        next unless valid_uris.keys.include? collection.name
        collection[:href].should =~ /#{valid_uris[collection.name]}$/
      end
    end

    def test_it_respond_to_json
      get_url '/cimi/cloudEntryPoint', {}, :format => :json
      JSON::parse(last_response.body).class.should == Hash
    end

    def test_json_include_all_properties
      get_url '/cimi/cloudEntryPoint', {}, :format => :json
      properties = ['uri', 'name', 'description', 'created', 'volumes', 'machines', 'machineImages', 'machineConfigurations'].sort
      properties.each do |property|
        JSON::parse(last_response.body).keys.include?(property).should == true
      end
    end

  end
end
