#
# Copyright (C) 2009  Red Hat, Inc.
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

describe "realms" do

  it_should_behave_like "all resources"

  it "should allow retrieval of all realms" do
    [API_URL, API_URL_REDIRECT].each do |entry_point|
      DeltaCloud.new( API_NAME, API_PASSWORD, entry_point ) do |client|
        realms = client.realms
        realms.should_not be_empty
        realms.each do |realm|
          realm.uri.should_not be_nil
          realm.uri.should be_a(String)
          realm.id.should_not be_nil
          realm.id.should be_a(String)
          realm.name.should_not be_nil
          realm.name.should be_a(String)
        end
      end
    end
  end


  it "should allow fetching a realm by id" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      realm = client.realm( 'us' )
      realm.should_not be_nil
      realm.id.should eql( 'us' )
      realm.name.should eql( 'United States' )
      realm.state.should eql( 'AVAILABLE' )
      realm = client.realm( 'eu' )
      realm.should_not be_nil
      realm.id.should eql( 'eu' )
      realm.name.should eql( 'Europe' )
      realm.state.should eql( 'AVAILABLE' )
    end
  end

  it "should allow fetching a realm by URI" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      realm = client.fetch_realm( API_URL + '/realms/us' )
      realm.should_not be_nil
      realm.id.should eql( 'us' )
    end
  end

end
