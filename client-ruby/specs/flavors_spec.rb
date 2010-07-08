
require 'specs/spec_helper'

describe "flavors" do

  it_should_behave_like "all resources"

  it "should allow retrieval of all flavors" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      flavors = client.flavors
      flavors.should_not be_empty
      flavors.each do |flavor|
        flavor.uri.should_not be_nil
        flavor.uri.should be_a(String)
        flavor.architecture.should_not be_nil
        flavor.architecture.should be_a(String)
        flavor.storage.should_not be_nil
        flavor.storage.should be_a(Float)
        flavor.memory.should_not be_nil
        flavor.memory.should be_a(Float)
      end
    end
  end 

  it "should allow filtering of flavors by architecture" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      flavors = client.flavors( :architecture=>'i386' )
      flavors.should_not be_empty
      flavors.size.should eql( 1 )
      flavors.first.architecture.should eql( 'i386' )
    end
  end

  it "should allow fetching a flavor by id" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      flavor = client.flavor( 'm1-small' )
      flavor.should_not be_nil
      flavor.resource_id.should eql( 'm1-small' )
    end
  end

  it "should allow fetching a flavor by URI" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      flavor = client.fetch_flavor( API_URL + '/flavors/m1-small' )
      flavor.should_not be_nil
      flavor.resource_id.should eql( 'm1-small' )
    end
  end

end
