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

describe Deltacloud::Client::StorageVolume do

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #attached?' do
    vol = @client.storage_volume('vol1')
    vol.attached?.must_equal false
    vol.attach('inst1')
    vol.attached?.must_equal true
    vol.detach!
  end

  it 'supports #snapshot!' do
    vol = @client.storage_volume('vol1')
    vol.snapshot!.must_be_instance_of Deltacloud::Client::StorageSnapshot
  end

  it 'supports #instance' do
    vol = @client.storage_volume('vol2')
    vol.attached?.must_equal false
    vol.attach('inst1')
    vol.attached?.must_equal true
    vol.instance.must_be_instance_of Deltacloud::Client::Instance
    vol.instance._id.must_equal 'inst1'
    vol.detach!
  end

end
