require 'specs/spec_helper'

describe "initializing the client" do

  it "should parse valid API URIs" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.api_host.should eql( API_HOST )
    client.api_port.should eql( API_PORT.to_i )
    client.api_path.should eql( API_PATH )
  end

  it "should discover entry points upon connection" do
    DeltaCloud.new( "name", "password", API_URL ) do |client|
      client.entry_points[:flavors].should           eql( "#{API_URL}/flavors" )
      client.entry_points[:images].should            eql( "#{API_URL}/images" )
      client.entry_points[:instances].should         eql( "#{API_URL}/instances" )
      client.entry_points[:storage_volumes].should   eql( "#{API_URL}/storage/volumes" )
      client.entry_points[:storage_snapshots].should eql( "#{API_URL}/storage/snapshots" )
    end  
  end

  it "should provide the current driver name via client" do
    DeltaCloud.new( "name", "password", API_URL ) do |client|
      client.driver_name.should eql( 'mock' )
    end
  end

  it "should provide the current driver name without client" do
    DeltaCloud.driver_name( API_URL ).should eql( 'mock' )
  end

  describe "without a block" do
    before( :each ) do
      reload_fixtures
    end
    it "should connect without a block" do
      client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
      client.images.should_not be_nil
    end
  end

end
