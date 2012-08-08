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

describe "initializing the client" do

  it "should parse valid API URIs" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.api_host.must_equal API_HOST
    client.api_port.must_equal API_PORT.to_i
    client.api_path.must_equal API_PATH
  end

  it "should discover entry points upon connection" do
    [API_URL, API_URL_REDIRECT].each do |entry_point|
      DeltaCloud.new( "name", "password", entry_point ) do |client|
        client.entry_points[:hardware_profiles].must_equal "#{API_URL}/hardware_profiles"
        client.entry_points[:images].must_equal "#{API_URL}/images"
        client.entry_points[:instances].must_equal "#{API_URL}/instances"
        client.entry_points[:storage_volumes].must_equal "#{API_URL}/storage_volumes"
        client.entry_points[:storage_snapshots].must_equal "#{API_URL}/storage_snapshots"
        client.entry_points[:buckets].must_equal "#{API_URL}/buckets"
        client.entry_points[:keys].must_equal "#{API_URL}/keys"
      end
    end
  end

  it "should provide the current driver name via client" do
    DeltaCloud.new( "name", "password", API_URL ) do |client|
      client.driver_name.must_equal 'mock'
    end
  end

  it "should provide the current driver name without client" do
    DeltaCloud.driver_name( API_URL ).must_equal 'mock'
  end

  describe "without a block" do
    it "should connect without a block" do
      client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
      client.images.wont_be_nil
    end
  end

end
