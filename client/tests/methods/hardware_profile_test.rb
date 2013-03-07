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

describe Deltacloud::Client::Methods::HardwareProfile do

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #hardware_profiles' do
    @client.must_respond_to :hardware_profiles
    @client.hardware_profiles.must_be_kind_of Array
    @client.hardware_profiles.each { |r| r.must_be_instance_of Deltacloud::Client::HardwareProfile }
  end

  it 'supports filtering #hardware_profiles by :id param' do
    result = @client.hardware_profiles(:id => 'm1-small')
    result.must_be_kind_of Array
    result.size.must_equal 1
    result.first.must_be_instance_of Deltacloud::Client::HardwareProfile
    result = @client.hardware_profiles(:id => 'unknown')
    result.must_be_kind_of Array
    result.size.must_equal 0
  end

  it 'support #hardware_profile' do
    @client.must_respond_to :hardware_profile
    result = @client.hardware_profile('m1-small')
    result.must_be_instance_of Deltacloud::Client::HardwareProfile
    lambda { @client.hardware_profile(nil) }.must_raise Deltacloud::Client::NotFound
    lambda { @client.hardware_profile('foo') }.must_raise Deltacloud::Client::NotFound
  end

end
