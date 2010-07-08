require 'specs/spec_helper'

describe "initializing the client" do

  it "should parse valid API URIs" do
    client = DeltaCloud.new( "name", "password", API_URL )
    client.api_host.should eql( "localhost" )
    client.api_port.should eql( 3000 )
    client.api_path.should eql( "/api" )
  end

  it "should discover entry points upon connection" do
    client = DeltaCloud.new( "name", "password", API_URL )
    client.connect do |client|
      client.entry_points[:flavors].should           eql( "#{API_URL}/flavors" )
      client.entry_points[:images].should            eql( "#{API_URL}/images" )
      client.entry_points[:instances].should         eql( "#{API_URL}/instances" )
      client.entry_points[:storage_volumes].should   eql( "#{API_URL}/storage/volumes" )
      client.entry_points[:storage_snapshots].should eql( "#{API_URL}/storage/snapshots" )
    end
  end

end
