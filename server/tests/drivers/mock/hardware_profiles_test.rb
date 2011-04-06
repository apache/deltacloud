# Copyright (C) 2009-2011  Red Hat, Inc.
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
#

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/common'

module DeltacloudUnitTest
  class HardwareProfilesTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_it_returns_hardware_profiles
      get_url '/api/hardware_profiles'
      (last_xml_response/'hardware_profiles/hardware_profile').length.should > 0
    end

    def test_it_has_correct_attributes_set
      get_auth_url '/api/hardware_profiles'
      (last_xml_response/'hardware_profiles/hardware_profile').each do |profile|
        profile.attributes.keys.sort.should == [ 'href', 'id' ]
      end
    end

    def test_hardware_profiles_have_name
      get_auth_url '/api/hardware_profiles'
      (last_xml_response/'hardware_profiles/hardware_profile').each do |profile|
        (profile/'name').text.should_not == nil
      end
    end

    def test_hardware_profiles_have_unique_name
      get_auth_url '/api/hardware_profiles'
      names = []
      (last_xml_response/'hardware_profiles/hardware_profile').each do |profile|
        names << (profile/'name').text
      end
      names.should == names.uniq
    end

    def test_hardware_profiles_have_unique_id
      get_auth_url '/api/hardware_profiles'
      ids = []
      (last_xml_response/'hardware_profiles/hardware_profile').each do |profile|
        ids << profile['id']
      end
      ids.should == ids.uniq
    end

    def test_m1_xlarge_profile_has_correct_attributes
      get_auth_url '/api/hardware_profiles'
      profile = (last_xml_response/'hardware_profiles/hardware_profile[@id="m1-xlarge"]')
      test_profile_properties(profile)
    end

    def test_it_returns_valid_hardware_profile
      get_auth_url '/api/hardware_profiles/m1-xlarge'
      profile = (last_xml_response/'hardware_profile')
      test_profile_properties(profile)
    end

    def test_it_responses_to_json
      get_url '/api/hardware_profiles', {}, { :format => :json }
      JSON::parse(last_response.body).class.should == Hash
      JSON::parse(last_response.body)['hardware_profiles'].class.should == Array
      get_url '/api/hardware_profiles/m1-xlarge', {}, { :format => :json }
      last_response.status.should == 200
      JSON::parse(last_response.body).class.should == Hash
      JSON::parse(last_response.body)['hardware_profile'].class.should == Hash
    end

    def test_it_responses_to_html
      get_url '/api/hardware_profiles', {}, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'
      get_url '/api/hardware_profiles/m1-xlarge', {}, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'
    end

    def test_it_returns_error_on_wrong_name
      get_url '/api/hardware_profiles/m1-unknown-wrongname', {}, { :format => :html }
      last_response.status.should == 404
      get_auth_url '/api/hardware_profiles/m1-unknown-wrongname'
      last_response.status.should == 404
      get_url '/api/hardware_profiles/m1-unknown-wrongname', {}, { :format => :json }
      last_response.status.should == 404
    end

    private

    def test_profile_properties(profile)
      (profile/'property').each do |properties|
        properties.attributes.keys.sort.should == [ 'kind', 'name', 'unit', 'value' ]
      end

      (profile/'property[@name="architecture"]').first['kind'].should == 'fixed'
      (profile/'property[@name="architecture"]').first['unit'].should == 'label'

      (profile/'property[@name="memory"]').first['kind'].should == 'range'
      (profile/'property[@name="memory"]').first['unit'].should == 'MB'
      (profile/'property[@name="memory"]/range').length.should == 1
      (profile/'property[@name="memory"]/range').first.attributes.keys.sort.should == [ 'first', 'last' ]

      (profile/'property[@name="cpu"]').first['kind'].should == 'fixed'
      (profile/'property[@name="cpu"]').first['unit'].should == 'count'

      (profile/'property[@name="storage"]').first['kind'].should == 'enum'
      (profile/'property[@name="storage"]').first['unit'].should == 'GB'
      (profile/'property[@name="storage"]/enum').length.should == 1
      (profile/'property[@name="storage"]/enum/entry').length.should == 3
      (profile/'property[@name="storage"]/enum/entry').each do |entry|
        entry.attributes.keys.should == [ 'value' ]
        entry['value'].should_not == nil
      end
    end

  end
end
