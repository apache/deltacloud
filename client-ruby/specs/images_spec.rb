
require 'specs/spec_helper'

describe "images" do

  it "should allow retrieval of all images" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      images = client.images
      images.should_not be_empty
      images.size.should eql( 3 )
      images.each do |image|
        image[:id].should_not be_nil
        image[:id].should be_a(String)
        image[:description].should_not be_nil
        image[:description].should be_a(String)
        image[:architecture].should_not be_nil
        image[:architecture].should be_a(String)
        image[:owner_id].should_not be_nil
        image[:owner_id].should be_a(String)
      end
    end
  end 

  it "should allow retrieval of my own images" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      images = client.images( :owner=>:self )
      images.should_not be_empty
      images.size.should eql( 1 )
      images.each do |image|
        image[:id].should_not be_nil
        image[:id].should be_a(String)
        image[:description].should_not be_nil
        image[:description].should be_a(String)
        image[:architecture].should_not be_nil
        image[:architecture].should be_a(String)
        image[:owner_id].should_not be_nil
        image[:owner_id].should be_a(String)
      end
    end
  end
end
