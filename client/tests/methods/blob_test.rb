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

describe Deltacloud::Client::Methods::Blob do

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #blobs' do
    @client.must_respond_to :blobs
    @client.blobs('bucket1').must_be_kind_of Array
    @client.blobs('bucket1').each { |r| r.must_be_instance_of Deltacloud::Client::Blob }
  end

  it 'support #blob' do
    @client.must_respond_to :blob
    result = @client.blob('bucket1', 'blob1')
    result.must_be_instance_of Deltacloud::Client::Blob
    lambda { @client.blob('bucket1', 'foo') }.must_raise Deltacloud::Client::NotFound
  end

  it 'support #create_blob and #destroy_blob' do
    @client.must_respond_to :create_blob
    result = @client.create_blob('bucket1', 'fooblob123', 'content_of_blob')
    result.must_be_instance_of Deltacloud::Client::Blob
    result.bucket_id.must_equal 'bucket1'
    result._id.must_equal 'fooblob123'
    result.content_length.must_equal '15'
    result.content_type.must_equal 'text/plain'
    @client.must_respond_to :destroy_blob
    @client.destroy_blob('bucket1', result._id).must_equal true
  end

  it 'support #create_blob and #destroy_blob with meta_params' do
    @client.must_respond_to :create_blob
    result = @client.create_blob('bucket1', 'fooblob123', 'content', :user_metadata => { :key => :value })
    result.must_be_instance_of Deltacloud::Client::Blob
    result.user_metadata.must_be_kind_of Hash
    result.user_metadata['key'].must_equal 'value'
    @client.must_respond_to :destroy_blob
    @client.destroy_blob('bucket1', result._id).must_equal true
  end

end
