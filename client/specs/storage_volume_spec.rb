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

describe "storage volumes" do

  it_should_behave_like "all resources"

  it "allow retrieval of all storage volumes owned by the current user" do
    [API_URL, API_URL_REDIRECT].each do |entry_point|
      client = DeltaCloud.new( API_NAME, API_PASSWORD, entry_point )
      client.connect do |client|
        storage_volumes = client.storage_volumes
        storage_volumes.should_not be_nil
        storage_volumes.should_not be_empty
        ids = storage_volumes.collect{|e| e.id}
        ids.size.should eql( 3 )
        ids.should include( 'vol2' )
        ids.should include( 'vol3' )
      end
    end
  end

  it "should allow fetching of storage volume by id" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |client|
      storage_volume = client.storage_volume( 'vol3' )
      storage_volume.id.should eql( 'vol3' )
      storage_volume.uri.should eql( API_URL + '/storage_volumes/vol3' )
      storage_volume.capacity.should eql( 1.0 )
      storage_volume.device.should eql( '/dev/sda1' )
      storage_volume.instance.should_not be_nil
      storage_volume.instance.id.should eql( 'inst1' )
      ip = storage_volume.instance
      ip.hardware_profile.architecture.value.should eql( 'i386' )
    end
  end

  it "should allow fetching of storage volume by URI" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |client|
      storage_volume = client.fetch_storage_volume( API_URL + '/storage_volumes/vol3' )
      storage_volume.should_not be_nil
      storage_volume.id.should eql( 'vol3' )
      storage_volume.uri.should eql( API_URL + '/storage_volumes/vol3' )
      storage_volume.capacity.should eql( 1.0 )
      storage_volume.device.should eql( '/dev/sda1' )
      storage_volume.instance.should_not be_nil
      storage_volume.instance.id.should eql( 'inst1' )
      ip = storage_volume.instance
      ip.hardware_profile.architecture.value.should eql( 'i386' )
    end
  end

  it "should raise exception for unknown storage volume by ID" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    lambda {
      client.connect do |client|
        client.storage_volume( 'bogus' )
      end
    }.should raise_error(DeltaCloud::HTTPError::NotFound)
  end

  it "should raise exception for unknown storage volume by URI" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    lambda {
      client.connect do |client|
        client.fetch_storage_volume( API_URL + '/storage_volumes/bogus' )
      end
    }.should raise_error(DeltaCloud::HTTPError::NotFound)
  end


end
