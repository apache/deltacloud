#
# Copyright (C) 2009-2011  Red Hat, Inc.
#
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

require 'specs/spec_helper'

def check_key(the_key, key_name = "")
  the_key.should_not be_nil
  the_key.id.should be_a(String)
  the_key.id.should eql(key_name)
  the_key.actions.should_not be_nil
  the_key.actions.size.should eql(1)
  the_key.actions.first[0].should eql("destroy")
  the_key.actions.first[1].should eql("#{API_URL}/keys/#{key_name}")
  the_key.fingerprint.should_not be_nil
  the_key.fingerprint.should be_a(String)
  the_key.pem.should_not be_nil
  the_key.pem.first.should be_a(String)
end

def create_key_if_necessary(client, key_name)
  the_key = client.key(key_name)
  unless the_key
    client.create_key()
  end
end


describe "keys" do

  it_should_behave_like "all resources"

  it "should allow retrieval of all keys" do
    [API_URL, API_URL_REDIRECT].each do |entry_point|
      DeltaCloud.new( API_NAME, API_PASSWORD, entry_point ) do |client|
        lambda{
              client.keys
              }.should_not raise_error
      end
    end
  end
end

describe "operations on keys" do

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
            }.should raise_error
    end
  end

  it "should allow successful destruction of an existing key" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      name = "my_new_key"
      create_key_if_necessary(client, name)
      the_key = client.key(name)
      lambda{
              the_key.destroy!
            }.should_not raise_error
    end
  end

end
