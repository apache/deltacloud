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

    def test_it_returns_instance_states
      do_xml_request '/api/instance_states', {}, true
      (last_xml_response/'states/state').length.should > 0
    end

    def test_each_state_has_transition
      do_xml_request '/api/instance_states', {}, true
      (last_xml_response/'states/state').each do |state|
        next if state['name'].eql?('finish') # Finnish state doesn't have transitions
        (state/'transition').length.should > 0
        (state/'transition').each do |transition|
          transition['to'].should_not == nil
        end
      end
    end

    def test_it_responses_to_json
      # FIXME: This test is suffering from conflict between JSON gem and Activesupport
      # gem in EC2.
      #
      #do_request '/api/instance_states', {}, false, { :format => :json }
      #JSON::parse(last_response.body).class.should == Array
      #JSON::parse(last_response.body).first['transitions'].class.should == Array
      #JSON::parse(last_response.body).first['name'].should == 'start'
    end

    def test_it_responses_to_html
      do_request '/api/instance_states', {}, false, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'
    end

    def test_it_responses_to_png
      do_request '/api/instance_states', { :format => 'png' }, false
      last_response.status.should == 200
      last_response.headers['Content-Type'].should =~ /^image\/png/
    end

  end
end
