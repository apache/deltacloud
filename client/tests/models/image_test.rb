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

describe Deltacloud::Client::Image do

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'support #original_body' do
    img = @client.image('img1')
    img.original_body.must_be_instance_of Faraday::Response
  end

  it 'supports #hardware_profiles' do
    img = @client.image('img1')
    img.must_respond_to :hardware_profiles
    img.hardware_profiles.wont_be_empty
    img.hardware_profiles.first.must_be_instance_of Deltacloud::Client::HardwareProfile
  end

  it 'supports #is_compatible?' do
    img = @client.image('img1')
    img.must_respond_to 'is_compatible?'
    img.is_compatible?('m1-small').must_equal true
    img.is_compatible?('m1-large').must_equal true
  end

  it 'supports #lunch_image' do
    img = @client.image('img1')
    img.must_respond_to :launch
    inst = img.launch(:hwp_id => 'm1-large')
    inst.must_be_instance_of Deltacloud::Client::Instance
    inst.hardware_profile_id.must_equal 'm1-large'
    inst.stop!
    inst.destroy!
  end

  it 'supports #id' do
    img = @client.image('img1')
    lambda { img.id.must_equal 'img1' }.must_output nil, "[DEPRECATION] `id` is deprecated because of a possible conflict with Object#id. Use `_id` instead.\n"
    img.must_respond_to :url
    img.url.must_equal 'http://localhost:3001/api/images/img1'
  end

end
