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

describe Deltacloud::Client::Methods::BackwardCompatibility do

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #api_host' do
    @client.must_respond_to :api_host
    @client.api_host.must_equal 'localhost'
  end

  it 'supports #api_port' do
    @client.must_respond_to :api_port
    @client.api_port.must_equal 3001
  end

  it 'supports #connect' do
    @client.must_respond_to :connect
    @client.connect do |new_client|
      new_client.must_be_instance_of Deltacloud::Client::Connection
    end
  end

  it 'supports #with_config' do
    @client.must_respond_to :with_config
    @client.with_config(:driver => :ec2, :username => 'f', :password => 'b') do |c|
      c.must_be_instance_of Deltacloud::Client::Connection
      c.current_driver.must_equal 'ec2'
      c.request_driver.must_equal :ec2
    end
  end

  it 'supports #use_driver' do
    @client.must_respond_to :use_driver
    @client.use_driver(:ec2, :username => 'f', :password => 'b') do |c|
      c.must_be_instance_of Deltacloud::Client::Connection
      c.current_driver.must_equal 'ec2'
      c.request_driver.must_equal :ec2
    end
  end

  it 'supports #discovered?' do
    @client.must_respond_to :"discovered?"
    @client.discovered?.must_equal true
  end

  it 'supports #valid_credentials? on class' do
    Deltacloud::Client.must_respond_to :"valid_credentials?"
    r = Deltacloud::Client.valid_credentials? DELTACLOUD_USER,
      DELTACLOUD_PASSWORD, DELTACLOUD_URL
    r.must_equal true
    r = Deltacloud::Client.valid_credentials? 'foo',
      DELTACLOUD_PASSWORD, DELTACLOUD_URL
    r.must_equal false
    r = Deltacloud::Client.valid_credentials? 'foo',
      'bar', DELTACLOUD_URL
    r.must_equal false
    lambda {
      Deltacloud::Client.valid_credentials? 'foo',
        'bar', 'http://unknown.local'
    }.must_raise Faraday::Error::ConnectionFailed
  end


end
