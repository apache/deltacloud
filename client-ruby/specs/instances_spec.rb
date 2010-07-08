
require 'specs/spec_helper'

describe "images" do

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
end
