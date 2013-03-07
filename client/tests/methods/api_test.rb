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

require_relative '../test_helper'

describe Deltacloud::Client::Methods::Api do

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #path' do
    @client.must_respond_to :path
    @client.path.must_be_kind_of String
    @client.path.must_equal '/api'
  end

  it 'supports #api_uri' do
    @client.must_respond_to :api_uri
    @client.api_uri('/sample').must_be_kind_of URI::Generic
    @client.api_uri('/sample').to_s.must_equal '/api/sample'
  end

  it 'supports #version' do
    @client.must_respond_to :version
    @client.version.must_equal '1.1.1'
  end

  it 'supports #current_driver' do
    @client.must_respond_to :current_driver
    @client.current_driver.must_equal 'mock'
  end

  it 'supports #current_provider' do
    @client.must_respond_to :current_provider
    @client.current_provider.must_be_nil
    @client.use(:ec2, 'foo', 'bar', 'eu-west-1').current_provider.must_equal 'eu-west-1'
  end

  it 'supports #supported_collections' do
    @client.must_respond_to :supported_collections
    @client.supported_collections.must_be_kind_of Array
    @client.supported_collections.wont_be_empty
    @client.supported_collections.must_include 'realms'
  end

  it 'supports #support?' do
    @client.must_respond_to :"support?"
    @client.support?('realms').must_equal true
    @client.support?(:realms).must_equal true
    @client.support?('foo').must_equal false
  end

  it 'supports #must_support!' do
    @client.must_respond_to :"must_support!"
    @client.must_support!(:realms).must_be_nil
    @client.must_support!('realms').must_be_nil
    lambda { @client.must_support!(:foo) }.must_raise @client.error(:not_supported)
  end

  it 'supports #features' do
    @client.must_respond_to :features
    @client.features.must_be_kind_of Hash
    @client.features['instances'].wont_be_nil
    @client.features['instances'].must_be_kind_of Array
    @client.features['instances'].wont_be_empty
    @client.features['instances'].must_include 'user_name'
    @client.features['instances'].wont_include nil
  end

  it 'supports #feature?' do
    @client.must_respond_to :"feature?"
    @client.feature?(:instances, 'user_name').must_equal true
    @client.feature?('instances', :user_name).must_equal true
    @client.feature?('instances', :foo).must_equal false
    @client.feature?(:foo, :foo).must_equal false
    @client.feature?(nil, nil).must_equal false
  end

end
