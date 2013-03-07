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

describe Deltacloud::Client::Driver do

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #[] to get providers' do
    @client.driver(:ec2).must_respond_to '[]'
    @client.driver(:ec2)['eu-west-1'].wont_be_nil
    @client.driver(:ec2)['eu-west-1'].must_be_instance_of Deltacloud::Client::Driver::Provider
    @client.driver(:ec2)['eu-west-1'].entrypoints.wont_be_empty
    @client.driver(:ec2)['foo'].must_be_nil
  end

  it 'support #[] on Provider' do
    drv = @client.driver(:ec2)
    drv['eu-west-1']['s3'].wont_be_empty
  end

end
