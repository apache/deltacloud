#
# Copyright (C) 2009  Red Hat, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


require 'specs/spec_helper'

describe "storage snapshot" do

  it_should_behave_like "all resources"

  it "allow retrieval of all storage volumes owned by the current user" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |client|
      storage_snapshots = client.storage_snapshots
      storage_snapshots.should_not be_nil
      storage_snapshots.should_not be_empty
      ids = storage_snapshots.collect{|e| e.id}
      ids.size.should eql( 2 )
      ids.should include( 'snap2' )
      ids.should include( 'snap3' )
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
      storage_snapshot = client.fetch_storage_snapshot( API_URL + '/storage/snapshots/snap2' )
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
      storage_snapshot = client.fetch_storage_snapshot( API_URL + '/storage/snapshots/bogus' )
      storage_snapshot.should be_nil
    end
  end

end
