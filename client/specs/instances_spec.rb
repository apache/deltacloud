#
# Copyright (C) 2009  Red Hat, Inc.
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.


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
        instance.image.should be_a( DeltaCloud::Image )
        instance.hardware_profile.should_not be_nil
        instance.hardware_profile.should be_a( DeltaCloud::HardwareProfile )
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
      instance.hardware_profile.should_not be_nil
      instance.hardware_profile.should_not be_nil
      instance.hardware_profile.uri.should eql( API_URL + "/hardware_profiles/m1-large" )
      instance.hardware_profile.memory.value.should eql(10240.0)
      instance.hardware_profile.storage.value.should eql(850.0)
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
      instance.hardware_profile.id.should eql( 'm1-large' )
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
      instance.hardware_profile.id.should eql( 'm1-large' )
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
      instance.hardware_profile.id.should eql( 'm1-xlarge' )
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
      instance.hardware_profile.id.should eql( 'm1-xlarge' )
      instance.hardware_profile.memory.value.should eql(12288.0)
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
      instance.hardware_profile.id.should eql( 'm1-xlarge' )
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
