require 'specs/spec_helper'

describe "realms" do

  it_should_behave_like "all resources"

  it "should allow retrieval of all realms" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      realms = client.realms
      realms.should_not be_empty
      realms.each do |realm|
        realm.uri.should_not be_nil
        realm.uri.should be_a(String)
        realm.id.should_not be_nil
        realm.id.should be_a(String)
        realm.name.should_not be_nil
        realm.name.should be_a(String)
      end
    end
  end 


  it "should allow fetching a realm by id" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      realm = client.realm( 'us' )
      realm.should_not be_nil
      realm.id.should eql( 'us' )
      realm.name.should eql( 'United States' )
      realm.state.should eql( 'AVAILABLE' )
      realm.limit.should eql( :unlimited )
      realm = client.realm( 'eu' )
      realm.should_not be_nil
      realm.id.should eql( 'eu' )
      realm.name.should eql( 'Europe' )
      realm.state.should eql( 'AVAILABLE' )
      realm.limit.should eql( :unlimited )
    end
  end

  it "should allow fetching a realm by URI" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      realm = client.fetch_realm( API_URL + '/realms/us' )
      realm.should_not be_nil
      realm.id.should eql( 'us' )
    end
  end

end
