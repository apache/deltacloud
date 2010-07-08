
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
