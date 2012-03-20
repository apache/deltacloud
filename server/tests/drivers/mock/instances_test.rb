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

module DeltacloudUnitTest
  class InstancesTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_it_require_authentication
      require_authentication?('/api/instances').should == true
    end

    def test_it_returns_instances
      get_auth_url '/api/instances', {}
      (last_xml_response/'instances/instance').length.should > 0
    end

    def test_it_has_correct_attributes_set
      get_auth_url '/api/images', {}
      (last_xml_response/'images/image').each do |image|
        image.attributes.keys.sort.should == [ 'href', 'id' ]
      end
    end

    def test_it_has_unique_ids
      get_auth_url '/api/instances', {}
      ids = []
      (last_xml_response/'instances/instance').each do |image|
        ids << image['id'].to_s
      end
      ids.sort.should == ids.sort.uniq
    end

    def test_inst1_has_correct_attributes
      get_auth_url '/api/instances', {}
      instance = (last_xml_response/'instances/instance[@id="inst1"]')
      test_instance_attributes(instance)
    end

    def test_it_returns_valid_realm
      get_auth_url '/api/instances/inst1', {}
      instance = (last_xml_response/'instance')
      test_instance_attributes(instance)
    end

    def test_it_responses_to_json
      get_auth_url '/api/instances', {}, { :format => :json }
      JSON::parse(last_response.body).class.should == Hash
      JSON::parse(last_response.body)['instances'].class.should == Array

      get_auth_url '/api/instances/inst1', {}, { :format => :json }
      last_response.status.should == 200
      JSON::parse(last_response.body).class.should == Hash
      JSON::parse(last_response.body)['instance'].class.should == Hash
    end

    def test_it_responses_to_html
      get_auth_url '/api/instances', {}, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'
      get_auth_url '/api/instances/inst1', {}, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'
    end

    def test_it_create_a_new_instance_using_image_id
      params = {
        :image_id => 'img1'
      }
      post_url '/api/instances', params
      last_response.status.should == 201
      last_response.headers['Location'].should_not == nil
      get_auth_url last_response.headers['Location'], {}
      (last_xml_response/'instance/name').should_not == nil
      add_created_instance (last_xml_response/'instance').first['id']
      test_instance_attributes(last_xml_response/'instance')
    end

    def test_it_create_a_new_instance_using_image_id_and_name
      params = {
        :image_id => 'img1',
        :name => "unit_test_instance1"
      }
      post_url '/api/instances', params
      last_response.status.should == 201
      last_response.headers['Location'].should_not == nil
      get_auth_url last_response.headers['Location'], {}
      (last_xml_response/'instance/name').text.should == 'unit_test_instance1'
      add_created_instance (last_xml_response/'instance').first['id']
      test_instance_attributes(last_xml_response/'instance')
    end

    def test_it_create_a_new_instance_using_image_id_and_name_and_hwp_storage_and_hwp_cpu
      params = {
        :image_id => 'img1',
        :realm_id => '',
        :name => "unit_test_instance3",
        :hwp_id => "m1-large",
        :hwp_storage => '850',
        :hwp_memory => '7680.0',
        :hwp_cpu => "1.0",
      }
      post_url '/api/instances', params
      last_response.status.should == 400
    end

    def test_it_create_a_new_instance_using_image_id_and_name_and_hwp_storage
      params = {
        :image_id => 'img1',
        :name => "unit_test_instance2",
        :hwp_id => "m1-small",
        :hwp_storage => "160"
      }
      post_url '/api/instances', params
      last_response.status.should == 201
      last_response.headers['Location'].should_not == nil
      get_auth_url last_response.headers['Location'], {}
      (last_xml_response/'instance/name').text.should == 'unit_test_instance2'
      (last_xml_response/'instance/hardware_profile').first['id'].should == 'm1-small'
      add_created_instance (last_xml_response/'instance').first['id']
      test_instance_attributes(last_xml_response/'instance')
    end

    def test_it_z0_stop_and_start_instance
      $created_instances.each do |instance_id|
        get_auth_url "/api/instances/#{instance_id}", {}
        stop_url = (last_xml_response/'actions/link[@rel="stop"]').first['href']
        stop_url.should_not == nil
        post_url stop_url
        last_response.status.should == 200
        instance = Nokogiri::XML(last_response.body)
        test_instance_attributes(instance)
        (instance/'state').text.should == 'STOPPED'
        get_auth_url "/api/instances/#{instance_id}", {}
        start_url = (last_xml_response/'actions/link[@rel="start"]').first['href']
        start_url.should_not == nil
        post_url start_url
        last_response.status.should == 200
        instance = Nokogiri::XML(last_response.body)
        test_instance_attributes(instance)
        (instance/'state').text.should == 'RUNNING'
      end
    end

    def test_z0_reboot_instance
      $created_instances.each do |instance_id|
        get_auth_url "/api/instances/#{instance_id}", {}
        reboot_url = (last_xml_response/'actions/link[@rel="reboot"]').first['href']
        reboot_url.should_not == nil
        post_url reboot_url
        last_response.status.should == 202
        instance = Nokogiri::XML(last_response.body)
        test_instance_attributes(instance)
        (instance/'state').text.should == 'RUNNING'
      end
    end

    def test_z1_stop_created_instances
      $created_instances.each do |instance_id|
        get_auth_url "/api/instances/#{instance_id}", {}
        stop_url = (last_xml_response/'actions/link[@rel="stop"]').first['href']
        stop_url.should_not == nil
        post_url stop_url, {}
        last_response.status.should == 200
        instance = Nokogiri::XML(last_response.body)
        test_instance_attributes(instance)
        (instance/'state').text.should == 'STOPPED'
      end
    end

    def test_z2_destroy_created_instances
      $created_instances.each do |instance_id|
        get_auth_url "/api/instances/#{instance_id}", {}
        destroy_url = (last_xml_response/'actions/link[@rel="destroy"]').first['href']
        destroy_url.should_not == nil
        delete_url destroy_url, {}
        last_response.status.should == 204
      end
    end

    def test_create_key_returns_201
      post_url '/api/keys', {:name => Time.now.to_f.to_s}
      last_response.status.should == 201
    end

    private

    def test_instance_attributes(instance)
      (instance/'name').should_not == nil
      (instance/'owner_id').should_not == nil
      ['RUNNING', 'STOPPED'].include?((instance/'state').text).should == true

      (instance/'public_addreses').should_not == nil
      (instance/'public_addresses/address').to_a.size.should > 0
      (instance/'public_addresses/address').first.text.should_not == ""
      (instance/'public_addresses/address').first[:type].should == "hostname"

      (instance/'private_addresses').should_not == nil
      (instance/'private_addresses/address').to_a.size.should > 0
      (instance/'private_addresses/address').first.text.should_not == ""
      (instance/'private_addresses/address').first[:type].should == "hostname"

      (instance/'actions/link').to_a.size.should > 0
      (instance/'actions/link').each do |link|
        link['href'].should_not == ""
        link['rel'].should_not == ""
        link['method'].should_not == ""
        ['get', 'post', 'delete', 'put'].include?(link['method']).should == true
      end

      (instance/'image').size.should > 0
      (instance/'image').first['href'].should_not == ""
      (instance/'image').first['id'].should_not == ""
      get_auth_url (instance/'image').first['href'], {}
      (last_xml_response/'image').should_not == nil
      (last_xml_response/'image').first['href'] == (instance/'image').first['href']

      (instance/'realm').size.should > 0
      (instance/'realm').first['href'].should_not == ""
      (instance/'realm').first['id'].should_not == ""
      get_auth_url (instance/'realm').first['href']
      (last_xml_response/'realm').should_not == nil
      (last_xml_response/'realm').first['href'] == (instance/'realm').first['href']

      (instance/'hardware_profile').size.should > 0
      (instance/'hardware_profile').first['href'].should_not == ""
      (instance/'hardware_profile').first['id'].should_not == ""
      get_auth_url (instance/'hardware_profile').first['href']
      (last_xml_response/'hardware_profile').should_not == nil
      (last_xml_response/'hardware_profile').first['href'] == (instance/'hardware_profile').first['href']
    end

  end
end
