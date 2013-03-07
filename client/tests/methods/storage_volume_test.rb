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

describe Deltacloud::Client::Methods::StorageVolume do

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #storage_volumes' do
    @client.must_respond_to :storage_volumes
    @client.storage_volumes.must_be_kind_of Array
    @client.storage_volumes.each { |r| r.must_be_instance_of Deltacloud::Client::StorageVolume }
  end

  it 'supports filtering #storage_volumes by :id param' do
    result = @client.storage_volumes(:id => 'vol1')
    result.must_be_kind_of Array
    result.size.must_equal 1
    result.first.must_be_instance_of Deltacloud::Client::StorageVolume
    result = @client.storage_volumes(:id => 'unknown')
    result.must_be_kind_of Array
    result.size.must_equal 0
  end

  it 'support #storage_volume' do
    @client.must_respond_to :storage_volume
    result = @client.storage_volume('vol1')
    result.must_be_instance_of Deltacloud::Client::StorageVolume
    lambda { @client.storage_volume(nil) }.must_raise Deltacloud::Client::NotFound
    lambda { @client.storage_volume('foo') }.must_raise Deltacloud::Client::NotFound
  end

  it 'support #create_volume and #destroy_volume' do
    @client.must_respond_to :create_storage_volume
    result = @client.create_storage_volume(:snapshot_id => 'snap1', :name => 'foo123', :capacity => '10')
    result.must_be_instance_of Deltacloud::Client::StorageVolume
    result.name.must_equal 'foo123'
    result.capacity.must_equal '10'
    @client.must_respond_to :destroy_storage_volume
    @client.destroy_storage_volume(result._id).must_equal true
    lambda { @client.storage_volume(result._id) }.must_raise Deltacloud::Client::NotFound
  end

  it 'support #attach_storage_volume and #detach_storage_volume' do
    @client.must_respond_to :attach_storage_volume
    result = @client.attach_storage_volume('vol1', 'inst1', '/dev/sdc')
    result.must_be_instance_of Deltacloud::Client::StorageVolume
    result.name.must_equal 'vol1'
    result.state.must_equal 'IN-USE'
    result.device.must_equal '/dev/sdc'
    result.mount[:instance].must_equal 'inst1'
    @client.must_respond_to :detach_storage_volume
    result = @client.detach_storage_volume('vol1')
    result.must_be_instance_of Deltacloud::Client::StorageVolume
    result.name.must_equal 'vol1'
    result.state.must_equal 'AVAILABLE'
    result.device.must_be_nil
    result.mount[:instance].must_be_nil
  end

end
