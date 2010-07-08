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
        instance.image.should be_a( DCloud::Image )
        instance.instance_profile.should_not be_nil
        instance.instance_profile.should be_a( DCloud::InstanceProfile )
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
      instance = client.instance( "inst0" )
      instance.should_not be_nil
      instance.name.should_not be_nil
      instance.name.should eql( 'Mock Instance With Profile Change' )
      instance.uri.should_not be_nil
      instance.uri.should be_a( String )
      instance.owner_id.should eql( "mockuser" )
      instance.public_addresses.first.should eql( "img1.inst0.public.com" )
      instance.image.should_not be_nil
      instance.image.uri.should eql( API_URL + "/images/img1" )
      instance.instance_profile.should_not be_nil
      instance.instance_profile.hardware_profile.should_not be_nil
      instance.instance_profile.hardware_profile.uri.should eql( API_URL + "/hardware_profiles/m1-large" )
      instance.instance_profile[:memory].should eql( "12288" )
      instance.instance_profile[:storage].should be_nil
      instance.state.should eql( "RUNNING" )
      instance.actions.should_not be_nil
    end
  end

  it "should allow creation of new instances with reasonable defaults" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.create_instance( 'img1', :name=>'TestInstance' )
      instance.should_not be_nil
      instance.uri.should match( %r{#{API_URL}/instances/inst[0-9]+} )
      instance.id.should match( /inst[0-9]+/ )
      instance.name.should eql( 'TestInstance' )
      instance.image.id.should eql( 'img1' )
      instance.instance_profile.id.should eql( 'm1-large' )
      instance.realm.id.should eql( 'us' )
    end
  end

  it "should allow creation of new instances with specific realm" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.create_instance( 'img1', :realm=>'eu' )
      instance.should_not be_nil
      instance.uri.should match( %r{#{API_URL}/instances/inst[0-9]+} )
      instance.id.should match( /inst[0-9]+/ )
      instance.image.id.should eql( 'img1' )
      instance.instance_profile.id.should eql( 'm1-large' )
      instance.realm.id.should eql( 'eu' )
    end
  end

  it "should allow creation of new instances with specific hardware profile" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.create_instance( 'img1',
                                         :hardware_profile=>'m1-xlarge' )
      instance.should_not be_nil
      instance.uri.should match( %r{#{API_URL}/instances/inst[0-9]+} )
      instance.id.should match( /inst[0-9]+/ )
      instance.image.id.should eql( 'img1' )
      instance.instance_profile.id.should eql( 'm1-xlarge' )
      instance.realm.id.should eql( 'us' )
    end
  end

  it "should allow creation of new instances with specific hardware profile overriding memory" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      hwp = { :id => 'm1-xlarge', :memory => 32768 }
      instance = client.create_instance( 'img1', :hardware_profile=> hwp )
      instance.should_not be_nil
      instance.uri.should match( %r{#{API_URL}/instances/inst[0-9]+} )
      instance.id.should match( /inst[0-9]+/ )
      instance.image.id.should eql( 'img1' )
      instance.instance_profile.id.should eql( 'm1-xlarge' )
      instance.instance_profile[:memory].should eql( "32768" )
      instance.realm.id.should eql( 'us' )
    end
  end

  it "should allow creation of new instances with specific realm and hardware profile" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.create_instance( 'img1', :realm=>'eu',
                                         :hardware_profile=>'m1-xlarge' )
      instance.should_not be_nil
      instance.uri.should match( %r{#{API_URL}/instances/inst[0-9]+} )
      instance.id.should match( /inst[0-9]+/ )
      instance.image.id.should eql( 'img1' )
      instance.instance_profile.id.should eql( 'm1-xlarge' )
      instance.realm.id.should eql( 'eu' )
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
      instance.id.should eql( 'inst1' )
    end
  end

  describe "performing actions on instances" do
    it "should allow actions that are valid" do
      DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
        instance = client.instance( 'inst1' )
        instance.should_not be_nil
        instance.state.should eql( "RUNNING" )
        instance.uri.should eql( API_URL + '/instances/inst1' )
        instance.id.should eql( 'inst1' )
        instance.stop!
        instance.state.should eql( "STOPPED" )
        instance.start!
        instance.state.should eql( "RUNNING" )
      end
    end

    it "should not allow actions that are invalid" do
      DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
        instance = client.instance( 'inst1' )
        instance.should_not be_nil
        instance.state.should eql( "RUNNING" )
        lambda{instance.start}.should raise_error
      end
    end
  end
end
