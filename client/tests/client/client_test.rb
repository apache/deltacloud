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

describe Deltacloud::Client do

  before do
    VCR.insert_cassette(__name__)
  end

  after do
    VCR.eject_cassette
  end

  it 'support #VERSION' do
    Deltacloud::Client::VERSION.wont_be_nil
  end

  it 'support #Client' do
    Deltacloud.must_respond_to 'Client'
  end

  it 'support to change driver with #Client' do
    client = Deltacloud::Client(
      DELTACLOUD_URL, DELTACLOUD_USER, DELTACLOUD_PASSWORD,
      :driver => :ec2
    )
    client.request_driver.must_equal :ec2
    client.current_driver.must_equal 'ec2'
  end

  it 'support to test of valid DC connection' do
    Deltacloud::Client.must_respond_to 'valid_connection?'
    Deltacloud::Client.valid_connection?(DELTACLOUD_URL).must_equal true
    Deltacloud::Client.valid_connection?('http://unknown:9999').must_equal false
  end

end
