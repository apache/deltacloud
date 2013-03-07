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

describe Deltacloud::Client::Methods::Bucket do

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #buckets' do
    @client.must_respond_to :buckets
    @client.buckets.must_be_kind_of Array
    @client.buckets.each { |r| r.must_be_instance_of Deltacloud::Client::Bucket }
  end

  it 'supports filtering #buckets by :id param' do
    result = @client.buckets(:id => 'bucket1')
    result.must_be_kind_of Array
    result.size.must_equal 1
    result.first.must_be_instance_of Deltacloud::Client::Bucket
    result = @client.buckets(:id => 'unknown')
    result.must_be_kind_of Array
    result.size.must_equal 0
  end

  it 'support #bucket' do
    @client.must_respond_to :bucket
    result = @client.bucket('bucket1')
    result.must_be_instance_of Deltacloud::Client::Bucket
    lambda { @client.bucket(nil) }.must_raise Deltacloud::Client::NotFound
    lambda { @client.bucket('foo') }.must_raise Deltacloud::Client::NotFound
  end

  it 'support #create_bucket and #destroy_bucket' do
    @client.must_respond_to :create_bucket
    b = @client.create_bucket('foo123')
    b.must_be_instance_of Deltacloud::Client::Bucket
    b.name.must_equal 'foo123'
    @client.destroy_bucket(b._id)
    lambda { @client.bucket(b._id) }.must_raise Deltacloud::Client::NotFound
  end

end
