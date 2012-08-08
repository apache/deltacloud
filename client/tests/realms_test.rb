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

require 'rubygems'
require 'require_relative' if RUBY_VERSION =~ /^1\.8/

require_relative './test_helper.rb'

describe "Realms" do

  before do
    @client = DeltaCloud.new(API_NAME, API_PASSWORD, API_URL)
  end

  it "should allow retrieval of all realms" do
    realms = @client.realms
    realms.wont_be_empty
    realms.each do |realm|
      realm.uri.wont_be_nil
      realm.uri.must_be_kind_of String
      realm.id.wont_be_nil
      realm.id.must_be_kind_of String
      realm.name.wont_be_nil
      realm.name.must_be_kind_of String
    end
  end


  it "should allow fetching a realm by id" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      realm = client.realm( 'us' )
      realm.wont_be_nil
      realm.id.must_equal 'us'
      realm.name.must_equal 'United States'
      realm.state.must_equal 'AVAILABLE'
      realm = client.realm( 'eu' )
      realm.wont_be_nil
      realm.id.must_equal 'eu'
      realm.name.must_equal 'Europe'
      realm.state.must_equal 'AVAILABLE'
    end
  end

  it "should allow fetching a realm by URI" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      realm = client.fetch_realm( API_URL + '/realms/us' )
      realm.wont_be_nil
      realm.id.must_equal 'us'
    end
  end

end
