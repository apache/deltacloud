
require 'specs/spec_helper'

describe "flavors" do

  it "should allow retrieval of all flavors" do
    DeltaCloud.new( "name", "password", API_URL ) do |client|
      puts client.flavors.inspect
    end
  end 
end
