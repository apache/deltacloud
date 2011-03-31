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
  class RealmsTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_it_not_require_authentication
      require_authentication?('/api/realms').should_not == true
    end

    def test_it_returns_realms
      do_xml_request '/api/realms', {}, true
      (last_xml_response/'realms/realm').length.should > 0
    end

    def test_it_has_correct_attributes_set
      do_xml_request '/api/realms', {}, true
      (last_xml_response/'realms/realm').each do |realm|
        realm.attributes.keys.sort.should == [ 'href', 'id' ]
      end
    end

    def test_us_has_correct_attributes
      do_xml_request '/api/realms', {}, true
      realm = (last_xml_response/'realms/realm[@id="us"]')
      test_realm_attributes(realm)
    end

    def test_it_returns_valid_realm
      do_xml_request '/api/realms/us', {}, true
      realm = (last_xml_response/'realm')
      test_realm_attributes(realm)
    end

    def test_it_has_unique_ids
      do_xml_request '/api/realms', {}, true
      ids = []
      (last_xml_response/'realms/realm').each do |realm|
        ids << realm['id'].to_s
      end
      ids.sort.should == ids.sort.uniq
    end

    def test_it_responses_to_json
      do_request '/api/realms', {}, false, { :format => :json }
      JSON::parse(last_response.body).class.should == Hash
      JSON::parse(last_response.body)['realms'].class.should == Array

      do_request '/api/realms/us', {}, false, { :format => :json }
      last_response.status.should == 200
      JSON::parse(last_response.body).class.should == Hash
      JSON::parse(last_response.body)['realm'].class.should == Hash
    end

    def test_it_responses_to_html
      do_request '/api/realms', {}, false, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'

      do_request '/api/realms/us', {}, false, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'
    end

    private

    def test_realm_attributes(realm)
      (realm/'name').should_not == nil
      (realm/'limit').should_not == nil
      ['AVAILABLE'].include?((realm/'state').text).should == true
    end

  end
end
