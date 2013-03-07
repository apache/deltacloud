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

describe Deltacloud::Client::Methods::Address do

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #addresses' do
    @client.must_respond_to :addresses
    @client.addresses.must_be_kind_of Array
    @client.addresses.each { |r| r.must_be_instance_of Deltacloud::Client::Address }
  end

  it 'supports filtering #addresses by :id param' do
    result = @client.addresses(:id => '192.168.0.1')
    result.must_be_kind_of Array
    result.size.must_equal 1
    result.first.must_be_instance_of Deltacloud::Client::Address
    result = @client.addresses(:id => 'unknown')
    result.must_be_kind_of Array
    result.size.must_equal 0
  end

  it 'support #address' do
    @client.must_respond_to :address
    result = @client.address('192.168.0.1')
    result.must_be_instance_of Deltacloud::Client::Address
    lambda { @client.address(nil) }.must_raise Deltacloud::Client::NotFound
    lambda { @client.address('foo') }.must_raise Deltacloud::Client::NotFound
  end

  it 'support #create_address' do
    @client.must_respond_to :create_address
    result = @client.create_address
    result.must_be_instance_of Deltacloud::Client::Address
    result.ip.wont_be_empty
    result.instance_id.must_be_nil
    @client.must_respond_to :destroy_address
    @client.destroy_address(result._id).must_equal true
    lambda { @client.address(result._id) }.must_raise Deltacloud::Client::NotFound
  end

end
