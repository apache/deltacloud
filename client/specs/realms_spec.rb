#
# Copyright (C) 2009  Red Hat, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

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
