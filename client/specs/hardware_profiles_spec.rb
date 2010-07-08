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

def prop_check(prop, value_class)
  if prop.present?
    prop.value.should_not be_nil
    prop.value.should be_a(value_class)
  end
end

describe "hardware_profiles" do

  it_should_behave_like "all resources"

  it "should allow retrieval of all hardware profiles" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      hardware_profiles = client.hardware_profiles
      hardware_profiles.should_not be_empty
      hardware_profiles.each do |hwp|
        hwp.uri.should_not be_nil
        hwp.uri.should be_a(String)
        prop_check(hwp.architecture, String)
        prop_check(hwp.storage, Float)
        prop_check(hwp.memory, Float)
      end
    end
  end

  it "should allow filtering of hardware_profiles by architecture" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      hardware_profiles = client.hardware_profiles( :architecture=>'i386' )
      hardware_profiles.should_not be_empty
      hardware_profiles.size.should eql( 2 )
      hardware_profiles.first.architecture.value.should eql( 'i386' )
    end
  end

  it "should allow fetching a hardware_profile by id" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      hwp = client.hardware_profile( 'm1-small' )
      hwp.should_not be_nil
      hwp.id.should eql( 'm1-small' )
    end
  end

  it "should allow fetching a hardware_profile by URI" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      hwp = client.fetch_hardware_profile( API_URL + '/hardware_profiles/m1-small' )
      hwp.should_not be_nil
      hwp.id.should eql( 'm1-small' )
    end
  end

end
