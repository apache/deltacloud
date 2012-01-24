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

describe "storage snapshot" do

  it_should_behave_like "all resources"

  it "allow retrieval of all storage volumes owned by the current user" do
    [API_URL, API_URL_REDIRECT].each do |entry_point|
      client = DeltaCloud.new( API_NAME, API_PASSWORD, entry_point )
      client.connect do |client|
        storage_snapshots = client.storage_snapshots
        storage_snapshots.should_not be_nil
        storage_snapshots.should_not be_empty
        ids = storage_snapshots.collect{|e| e.id}
        ids.size.should eql( 3 )
        ids.should include( 'snap2' )
        ids.should include( 'snap3' )
      end
    end
  end

  it "should allow fetching of storage volume by id" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |client|
      storage_snapshot = client.storage_snapshot( 'snap2' )
      storage_snapshot.should_not be_nil
      storage_snapshot.id.should eql( 'snap2' )
      storage_snapshot.storage_volume.capacity.should eql( 1.0 )
      storage_snapshot.storage_volume.id.should eql( 'vol2' )
    end
  end

  it "should allow fetching of storage volume by URI"  do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |client|
      storage_snapshot = client.fetch_storage_snapshot( API_URL + '/storage_snapshots/snap2' )
      storage_snapshot.should_not be_nil
      storage_snapshot.id.should eql( 'snap2' )
      storage_snapshot.storage_volume.capacity.should eql( 1.0 )
      storage_snapshot.storage_volume.id.should eql( 'vol2' )
    end
  end

  it "should return nil for unknown storage volume by ID" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |client|
      storage_snapshot = client.storage_snapshot( "bogus" )
      storage_snapshot.should be_nil
    end
  end

  it "should return nil for unknown storage volume by URI" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |client|
      storage_snapshot = client.fetch_storage_snapshot( API_URL + '/storage_snapshots/bogus' )
      storage_snapshot.should be_nil
    end
  end

end
