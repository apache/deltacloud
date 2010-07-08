
require 'specs/spec_helper'

describe "images" do

  it_should_behave_like "all resources"

  it "should allow retrieval of all images" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      images = client.images
      images.should_not be_empty
      images.size.should eql( 3 )
      images.each do |image|
        image.uri.should_not be_nil
        image.uri.should be_a(String)
        image.description.should_not be_nil
        image.description.should be_a(String)
        image.architecture.should_not be_nil
        image.architecture.should be_a(String)
        image.owner_id.should_not be_nil
        image.owner_id.should be_a(String)
      end
    end
  end 

  it "should allow retrieval of my own images" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      images = client.images( :owner_id=>:self )
      images.should_not be_empty
      images.size.should eql( 1 )
      images.each do |image|
        image.uri.should_not be_nil
        image.uri.should be_a(String)
        image.description.should_not be_nil
        image.description.should be_a(String)
        image.architecture.should_not be_nil
        image.architecture.should be_a(String)
        image.owner_id.should_not be_nil
        image.owner_id.should be_a(String)
      end
    end
  end

  it "should allow retrieval of a single image by ID" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      image = client.image( 'img1' )
      image.should_not be_nil
      image.uri.should eql( API_URL + '/images/img1' )
      image.id.should eql( 'img1' )
      image.architecture.should eql( 'x86_64' )
    end
  end

  it "should allow retrieval of a single image by URI" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      image = client.fetch_image( API_URL + '/images/img1' )
      image.should_not be_nil
      image.uri.should eql( API_URL + '/images/img1' )
      image.id.should eql( 'img1' )
      image.architecture.should eql( 'x86_64' )
    end
  end

  describe "filtering by architecture" do
    it "return matching images" do
      DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
        images = client.images( :architecture=>'x86_64' )
        images.should_not be_empty
        images.each do |image|
          image.architecture.should eql( 'x86_64' )
        end
        images = client.images( :architecture=>'i386' )
        images.should_not be_empty
        images.each do |image|
          image.architecture.should eql( 'i386' )
        end
      end
    end

    it "should return an empty array for no matches" do
      DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
        images = client.images( :architecture=>'8088' )
        images.should be_empty
      end
    end
  end
end
