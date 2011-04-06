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

    def test_it_require_authentication
      require_authentication?('/api/images').should == true
    end

    def test_it_returns_images
      get_auth_url '/api/images', {}
      (last_xml_response/'images/image').length.should > 0
    end

    def test_it_has_correct_attributes_set
      get_auth_url '/api/images', {}
      (last_xml_response/'images/image').each do |image|
        image.attributes.keys.sort.should == [ 'href', 'id' ]
      end
    end

    def test_img1_has_correct_attributes
      get_auth_url '/api/images', {}
      image = (last_xml_response/'images/image[@id="img1"]')
      test_image_attributes(image)
    end

    def test_it_returns_valid_image
      get_auth_url '/api/images/img1', {}
      image = (last_xml_response/'image')
      test_image_attributes(image)
    end

    def test_it_has_unique_ids
      get_auth_url '/api/images', {}
      ids = []
      (last_xml_response/'images/image').each do |image|
        ids << image['id'].to_s
      end
      ids.sort.should == ids.sort.uniq
    end

    def test_it_has_valid_urls
      get_auth_url '/api/images', {}
      ids = []
      images = (last_xml_response/'images/image')
      images.each do |image|
        get_auth_url image['href'].to_s, {}
        (last_xml_response/'image').first['href'].should == image['href'].to_s
      end
    end

    def test_it_can_filter_using_owner_id
      get_auth_url '/api/images', { :owner_id => 'mockuser' }
      (last_xml_response/'images/image').length.should == 1
      (last_xml_response/'images/image/owner_id').first.text.should == 'mockuser'
    end

    def test_it_can_filter_using_unknown_owner_id
      get_auth_url '/api/images', { :architecture => 'unknown_user' }
      (last_xml_response/'images/image').length.should == 0
    end

    def test_it_can_filter_using_architecture
      get_auth_url '/api/images', { :architecture => 'x86_64' }
      (last_xml_response/'images/image').length.should == 1
      (last_xml_response/'images/image/architecture').first.text.should == 'x86_64'
    end

    def test_it_can_filter_using_unknown_architecture
      get_auth_url '/api/images', { :architecture => 'unknown_arch' }
      (last_xml_response/'images/image').length.should == 0
    end

    def test_it_responses_to_json
      get_auth_url '/api/images', {}, { :format => :json }
      JSON::parse(last_response.body).class.should == Hash
      JSON::parse(last_response.body)['images'].class.should == Array
      get_auth_url '/api/images/img1', {}, { :format => :json }
      last_response.status.should == 200
      JSON::parse(last_response.body).class.should == Hash
      JSON::parse(last_response.body)['image'].class.should == Hash
    end

    def test_it_responses_to_html
      get_auth_url '/api/images', {}, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'
      get_auth_url '/api/images/img1', {}, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'
    end

    private

    def test_image_attributes(image)
      (image/'name').text.should_not nil
      (image/'owner_id').text.should_not nil
      (image/'description').text.should_not nil
      (image/'architecture').text.should_not nil
    end

  end
end
