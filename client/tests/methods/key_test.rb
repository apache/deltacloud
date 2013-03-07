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

describe Deltacloud::Client::Methods::Key do

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #keys' do
    @client.must_respond_to :keys
    @client.keys.must_be_kind_of Array
    @client.keys.each { |r| r.must_be_instance_of Deltacloud::Client::Key }
  end

  it 'supports filtering #keys by :id param' do
    result = @client.keys(:id => 'test-key')
    result.must_be_kind_of Array
    result.size.must_equal 1
    result.first.must_be_instance_of Deltacloud::Client::Key
    result = @client.keys(:id => 'unknown')
    result.must_be_kind_of Array
    result.size.must_equal 0
  end

  it 'support #key' do
    @client.must_respond_to :key
    result = @client.key('test-key')
    result.must_be_instance_of Deltacloud::Client::Key
    lambda { @client.key(nil) }.must_raise Deltacloud::Client::NotFound
    lambda { @client.key('foo') }.must_raise Deltacloud::Client::NotFound
  end

  it 'support #create_key and #destroy_key' do
    @client.must_respond_to :create_key
    result = @client.create_key('foo')
    result.must_be_instance_of Deltacloud::Client::Key
    result.name.must_equal 'foo'
    result.public_key.wont_be_nil
    @client.must_respond_to :destroy_key
    @client.destroy_key(result._id)
  end

end
