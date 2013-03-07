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

describe Deltacloud::Client::Methods::InstanceState do

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #instance_states' do
    @client.must_respond_to :instance_states
    @client.instance_states.must_be_kind_of Array
    @client.instance_states.each { |r| r.must_be_instance_of Deltacloud::Client::InstanceState::State }
  end

  it 'support #instance_state' do
    @client.must_respond_to :instance_state
    result = @client.instance_state('start')
    result.must_be_instance_of Deltacloud::Client::InstanceState::State
    @client.instance_state(nil).must_be_nil
    @client.instance_state('foo').must_be_nil
  end

end
