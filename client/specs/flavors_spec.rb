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
      flavor.id.should eql( 'm1-small' )
    end
  end

  it "should allow fetching a flavor by URI" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      flavor = client.fetch_flavor( API_URL + '/flavors/m1-small' )
      flavor.should_not be_nil
      flavor.id.should eql( 'm1-small' )
    end
  end

end
