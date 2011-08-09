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
  class ApiTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_it_returns_entry_points
      get_auth_url '/api'
      (last_xml_response/'/api/link').length.should > 0
    end

    def test_it_has_correct_attributes_set
      get_auth_url '/api'
      (last_xml_response/'/api/link').each do |link|
        link.attributes.keys.sort.should == [ 'href', 'rel' ]
      end
    end

    def test_it_responses_to_html
      get_url '/api', {}, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'
    end

    def test_it_responses_to_json
      get_url '/api', {}, { :format => :json }
      last_response.status.should == 200
      JSON::parse(last_response.body).class.should == Hash
      JSON::parse(last_response.body)['api'].class.should == Hash
    end

    def test_it_switches_drivers
      with_provider("") do
        get_auth_url '/api'
        (last_xml_response/"api/link[rel = 'instances']").first.should_not == nil
      end

      # Switch to storage-only mock driver
      with_provider("storage") do
        get_auth_url '/api'
        (last_xml_response/"api/link[rel = 'instances']").first.should == nil
      end
    end

    def test_it_handles_unsupported_collections
      get_auth_url '/api/no_such_collection'
      last_response.status.should == 404

      with_provider("storage") do
        get_auth_url '/api/instances'
        last_response.status.should == 403
      end
    end

    def test_it_allows_accessing_docs
      get_url '/api/docs/instances'
      last_response.status.should == 200

      with_provider("storage") do
        get_url '/api/docs/instances'
        last_response.status.should == 403
      end
    end

    def test_it_respond_to_head
      head '/api/instances'
      last_response.headers['Allow'].should_not == nil
      last_response.headers['Allow'].split(',').include?('HEAD').should == true
    end

    def test_it_expose_available_drivers
      get_auth_url '/api/drivers'
      last_response.status.should == 200
      (last_xml_response/"drivers").length.should > 0
      (last_xml_response/'drivers/driver').length.should > 0
      (last_xml_response/"drivers/driver[@id = 'mock']").length.should == 1
    end

    def test_it_expose_ec2_driver_entrypoints
      get_auth_url '/api/drivers'
      last_response.status.should == 200
      ec2 = (last_xml_response/'drivers/driver[@id=ec2]').first
      (ec2/"provider").length.should > 0
      (ec2/"provider[@id = 'eu-west-1']").length.should == 1
      get_auth_url ec2[:href]
      eu_west = (last_xml_response/"provider[@id = 'eu-west-1']").first
      (eu_west/"entrypoint").length.should > 0
      (eu_west/"entrypoint[@kind = 'ec2']").length.should == 1
    end

    def test_it_supports_matrix_params
      get_auth_url "/api;driver=ec2"
      last_response.status.should == 200
      (last_xml_response/'api').first[:driver].should == 'ec2'
      get_auth_url "/api;driver=mock"
      (last_xml_response/'api').first[:driver].should == 'mock'
      get_auth_url "/api;driver=ec2/hardware_profiles"
      (last_xml_response/'hardware_profiles/hardware_profile/@id').map {|n| n.to_s}.include?('m1.small').should == true
      last_response.status.should == 200
    end

    def test_it_change_features_after_driver_change
      get_auth_url "/api;driver=ec2"
      (last_xml_response/'api/link[@rel="instances"]/feature[@name="user_name"]').first.should == nil
      (last_xml_response/'api/link[@rel="instances"]/feature[@name="user_data"]').first.should_not == nil
      get_auth_url "/api;driver=mock"
      (last_xml_response/'api/link[@rel="instances"]/feature[@name="user_name"]').first.should_not == nil
      (last_xml_response/'api/link[@rel="instances"]/feature[@name="firewalls"]').first.should == nil
    end

  end
end
