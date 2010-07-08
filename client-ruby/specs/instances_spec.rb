
require 'specs/spec_helper'

describe "instances" do

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
        instance.public_addresses.should_not be_nil
        instance.public_addresses.should_not be_empty
        instance.public_addresses.should be_a( Array )
        instance.private_addresses.should_not be_nil
        instance.private_addresses.should_not be_empty
        instance.private_addresses.should be_a( Array )
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
      instance.public_addresses.first.should eql( "img3.inst1.public.com" )
      instance.image.should_not be_nil
      instance.image.uri.should eql( API_URL + "/images/img3" )
      instance.flavor.should_not be_nil
      instance.flavor.uri.should eql( API_URL + "/flavors/m1-small" )
      instance.state.should eql( "RUNNING" )
      instance.actions.should_not be_nil
    end
  
  end

  it "should allow creation of new instances" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.create_instance( 'img1', 'm1-small' )
      instance.should_not be_nil
      instance.uri.should eql( API_URL + '/instances/inst3' )
      instance.resource_id.should eql( 'inst3' )

      instance = client.create_instance( 'img1', 'm1-small' )
      instance.should_not be_nil
      instance.uri.should eql( API_URL + '/instances/inst4' )
      instance.resource_id.should eql( 'inst4' )
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
