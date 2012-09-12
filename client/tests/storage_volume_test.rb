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

describe "Storage Volumes" do

  it "allow retrieval of all storage volumes owned by the current user" do
    [API_URL, API_URL_REDIRECT].each do |entry_point|
      client = DeltaCloud.new( API_NAME, API_PASSWORD, entry_point )
      client.connect do |c|
        storage_volumes = c.storage_volumes
        storage_volumes.wont_be_nil
        storage_volumes.wont_be_nil
        ids = storage_volumes.collect{|e| e.id}
        ids.size.must_equal 3
        ids.must_include 'vol1'
        ids.must_include 'vol3'
      end
    end
  end

  it "should allow fetching of storage volume by id" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |c|
      storage_volume = c.storage_volume( 'vol3' )
      storage_volume.id.must_equal 'vol3'
      storage_volume.uri.must_equal API_URL + '/storage_volumes/vol3'
      storage_volume.capacity.must_equal 1.0
      storage_volume.device.must_equal '/dev/sda1'
      storage_volume.instance.wont_be_nil
      storage_volume.instance.id.must_equal 'inst1'
      ip = storage_volume.instance
      ip.hardware_profile.architecture.value.must_equal 'i386'
    end
  end

  it "should allow fetching of storage volume by URI" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |c|
      storage_volume = c.fetch_storage_volume( API_URL + '/storage_volumes/vol3' )
      storage_volume.wont_be_nil
      storage_volume.id.must_equal 'vol3'
      storage_volume.uri.must_equal API_URL + '/storage_volumes/vol3'
      storage_volume.capacity.must_equal 1.0
      storage_volume.device.must_equal '/dev/sda1'
      storage_volume.instance.wont_be_nil
      storage_volume.instance.id.must_equal 'inst1'
      ip = storage_volume.instance
      ip.hardware_profile.architecture.value.must_equal 'i386'
    end
  end

  it "should raise exception for unknown storage volume by ID" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    lambda {
      client.connect do |c|
        c.storage_volume( 'bogus' )
      end
    }.must_raise DeltaCloud::HTTPError::NotFound
  end

  it "should raise exception for unknown storage volume by URI" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    lambda {
      client.connect do |c|
        client.fetch_storage_volume( API_URL + '/storage_volumes/bogus' )
      end
    }.must_raise DeltaCloud::HTTPError::NotFound
  end


end
