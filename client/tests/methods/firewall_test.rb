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

describe Deltacloud::Client::Methods::Firewall do

  def new_client
    Deltacloud::Client(DELTACLOUD_URL, 'AKIAJYOQYLLOIWN5LQ3A', 'Ra2ViYaYgocAJqPAQHxMVU/l2sGGU2pifmWT4q3H', :driver => :ec2 )
  end

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #firewalls' do
    @client.must_respond_to :firewalls
    begin
      @client.firewalls.must_be_kind_of Array
    rescue Deltacloud::Client::AuthenticationError
      skip
    end
    @client.firewalls.each { |r| r.must_be_instance_of Deltacloud::Client::Firewall }
  end

  it 'supports filtering #firewalls by :id param' do
    begin
      result = @client.firewalls(:id => 'mfojtik')
    rescue Deltacloud::Client::AuthenticationError
      skip
    end
    result.must_be_kind_of Array
    result.size.must_equal 1
    result.first.must_be_instance_of Deltacloud::Client::Firewall
  end

  it 'support #firewall' do
    @client.must_respond_to :firewall
    begin
      result = @client.firewall('mfojtik')
    rescue
      skip
    end
    result.must_be_instance_of Deltacloud::Client::Firewall
    lambda { @client.firewall(nil) }.must_raise Deltacloud::Client::NotFound
    lambda { @client.firewall('foo') }.must_raise Deltacloud::Client::NotFound
  end

  it 'support #create_firewall and #destroy_firewall' do
    @client.must_respond_to :create_firewall
    @client.must_respond_to :destroy_firewall
    begin
      result = @client.create_firewall('foofirewall', :description => 'testing firewalls')
      result.must_be_instance_of Deltacloud::Client::Firewall
      result.name.must_equal 'foofirewall'
      @client.destroy_firewall(result._id).must_equal true
      lambda {
        @client.create_firewall('foofirewall')
      }.must_raise Deltacloud::Client::ClientFailure
    rescue
      skip
    end
  end


  # FIXME: TBD, not supported by mock driver yet.
end
