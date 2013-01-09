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

require 'rubygems'
require 'require_relative' if RUBY_VERSION =~ /^1\.8/

require_relative './test_helper.rb'

def check_key(the_key, key_name = "")
  the_key.wont_be_nil
  the_key.id.must_be_kind_of String
  the_key.id.must_equal key_name
  the_key.actions.wont_be_nil
  the_key.actions.size.must_equal 1
  the_key.actions.first[0].must_equal "destroy"
  the_key.actions.first[1].must_equal "#{API_URL}/keys/#{key_name}"
  the_key.fingerprint.wont_be_nil
  the_key.fingerprint.must_be_kind_of String
  the_key.pem.wont_be_nil
  the_key.pem.must_be_kind_of String
end

def create_key_if_necessary(client, key_name)
  the_key = client.key(key_name)
  unless the_key
    client.create_key()
  end
end


describe "Keys" do
  it "should allow retrieval of all keys" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      client.keys.wont_be_empty
    end
  end
end

describe "Operations on Keys" do

  it "should allow successful creation of a new key" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      new_key = client.create_key({:name => "my_new_key"})
      check_key(new_key, "my_new_key")
    end
  end

  it "should allow retrieval of an existing named key" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      key_name = "my_new_key"
      create_key_if_necessary(client, key_name)
      the_key = client.key(key_name)
      check_key(the_key, key_name)
    end
  end

  it "should raise error if you create a key with the same name as an existing key" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      name = "my_new_key"
      create_key_if_necessary(client, name)
      lambda{
              client.create_key({:name => name})
            }.must_raise DeltaCloud::HTTPError::Forbidden
    end
  end

  it "should allow successful destruction of an existing key" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      name = "my_new_key"
      create_key_if_necessary(client, name)
      the_key = client.key(name)
      the_key.destroy!.must_be_nil
    end
  end

end
