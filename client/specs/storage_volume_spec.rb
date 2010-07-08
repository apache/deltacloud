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

describe "storage volumes" do

  it_should_behave_like "all resources"

  it "allow retrieval of all storage volumes owned by the current user" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |client|
      storage_volumes = client.storage_volumes
      storage_volumes.should_not be_nil
      storage_volumes.should_not be_empty
      ids = storage_volumes.collect{|e| e.id}
      ids.size.should eql( 2 )
      ids.should include( 'vol2' )
      ids.should include( 'vol3' )
    end
  end

  it "should allow fetching of storage volume by id" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |client|
      storage_volume = client.storage_volume( 'vol3' )
      storage_volume.id.should eql( 'vol3' )
      storage_volume.uri.should eql( API_URL + '/storage_volumes/vol3' )
      storage_volume.state.should eql( 'IN-USE' )
      storage_volume.capacity.should eql( 1.0 )
      storage_volume.device.should eql( '/dev/sda1' )
      storage_volume.instance.should_not be_nil
      storage_volume.instance.id.should eql( 'inst1' )
      ip = storage_volume.instance.instance_profile
      ip.hardware_profile.architecture.value.should eql( 'i386' )
    end
  end

  it "should allow fetching of storage volume by URI" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |client|
      storage_volume = client.fetch_storage_volume( API_URL + '/storage_volumes/vol3' )
      storage_volume.should_not be_nil
      storage_volume.id.should eql( 'vol3' )
      storage_volume.uri.should eql( API_URL + '/storage_volumes/vol3' )
      storage_volume.state.should eql( 'IN-USE' )
      storage_volume.capacity.should eql( 1.0 )
      storage_volume.device.should eql( '/dev/sda1' )
      storage_volume.instance.should_not be_nil
      storage_volume.instance.id.should eql( 'inst1' )
      ip = storage_volume.instance.instance_profile
      ip.hardware_profile.architecture.value.should eql( 'i386' )
    end
  end

  it "should return nil for unknown storage volume by ID" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |client|
      storage_volume = client.storage_volume( 'bogus' )
      storage_volume.should be_nil
    end
  end

  it "should return nil for unknown storage volume by URI" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    client.connect do |client|
      storage_volume = client.fetch_storage_volume( API_URL + '/storage_volumes/bogus' )
      storage_volume.should be_nil
    end
  end


end
