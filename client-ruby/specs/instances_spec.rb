
require 'specs/spec_helper'

describe "images" do

  it_should_behave_like "all resources"

  it "should allow retrieval of all instances" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instances = client.instances
      instances.should_not be_empty
      instances.each do |instance|
        instance.uri.should_not be_nil
        instance.uri.should be_a( String )
        instance.owner_id.should_not be_nil
        instance.owner_id.should be_a( String )
        instance.image.should_not be_nil
        instance.image.should be_a( Image )
        instance.flavor.should_not be_nil
        instance.flavor.should be_a( Flavor )
        instance.state.should_not be_nil
        instance.state.should be_a( String )
        instance.public_address.should_not be_nil
        instance.public_address.should be_a( String )
        instance.private_address.should_not be_nil
        instance.private_address.should be_a( String )
      end
    end
  end 

  it "should allow navigation from instance to image" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instances = client.instances
      instances.should_not be_empty
      instance = instances.first
      instance.image.should_not be_nil
      instance.image.description.should_not be_nil
      instance.image.description.should be_a(String)
    end
  end

  it "should allow retrieval of a single instance" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.instance( "inst1" )
      instance.should_not be_nil
      instance.uri.should_not be_nil
      instance.uri.should be_a( String )
      instance.owner_id.should eql( "mockuser" )
      instance.public_address.should eql( "img3.inst1.public.com" )
    end
  
  end

  it "should allow creation of new instances" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.create_instance( 'img1', 'm1-small' )
      instance.should_not be_nil
      instance.uri.should_not be_nil
      instance.uri.should be_a( String )
    end
  end

  it "should allow fetching of instances by id" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.instance( 'inst1' )
      instance.should_not be_nil
      instance.uri.should_not be_nil
      instance.uri.should be_a( String )
    end
  end

  it "should allow fetching of instances by URI" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.fetch_instance( API_URL + '/instances/inst1' )
      instance.should_not be_nil
      instance.uri.should eql( API_URL + '/instances/inst1' )
      instance.resource_id.should eql( 'inst1' )
    end
  end
end
