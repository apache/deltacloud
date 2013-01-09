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

require 'rubygems'
require 'require_relative' if RUBY_VERSION =~ /^1\.8/

require_relative './test_helper.rb'

describe "Instances" do

  it "should allow retrieval of all instances" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instances = client.instances
      instances.wont_be_empty
      instances.each do |instance|
        instance.uri.wont_be_nil
        instance.uri.must_be_kind_of String
        instance.owner_id.wont_be_nil
        instance.owner_id.must_be_kind_of String
        instance.image.wont_be_nil
        instance.image.to_s.must_match /DeltaCloud::API::.*::Image/
        instance.hardware_profile.wont_be_nil
        instance.hardware_profile.must_be_kind_of DeltaCloud::API::Base::HardwareProfile
        instance.state.wont_be_nil
        instance.state.must_be_kind_of String
        instance.public_addresses.wont_be_nil
        instance.public_addresses.wont_be_empty
        instance.public_addresses.must_be_kind_of Array
        instance.private_addresses.wont_be_nil
        instance.private_addresses.wont_be_empty
        instance.private_addresses.must_be_kind_of Array
      end
    end
  end

  it "should allow navigation from instance to image" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instances = client.instances
      instances.wont_be_empty
      instance = instances.first
      instance.image.wont_be_nil
      instance.image.description.wont_be_nil
      instance.image.description.must_be_kind_of String
    end
  end

  it "should allow retrieval of a single instance" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.instance( "inst0" )
      instance.wont_be_nil
      instance.name.wont_be_nil
      instance.name.must_equal 'Mock Instance With Profile Change'
      instance.uri.wont_be_nil
      instance.uri.must_be_kind_of String
      instance.owner_id.must_equal "mockuser"
      instance.public_addresses.first.class.must_equal Hash
      instance.public_addresses.first[:type].must_equal 'hostname'
      instance.public_addresses.first[:address].must_equal 'img1.inst0.public.com'
      instance.image.wont_be_nil
      instance.image.uri.must_equal API_URL + "/images/img1"
      instance.hardware_profile.wont_be_nil
      instance.hardware_profile.wont_be_nil
      instance.hardware_profile.uri.must_equal API_URL + "/hardware_profiles/m1-large"
      instance.hardware_profile.memory.value.must_equal '10240'
      instance.hardware_profile.storage.value.must_equal '850'
      instance.state.must_equal "RUNNING"
      instance.actions.wont_be_nil
    end
  end

  it "should allow creation of new instances with reasonable defaults" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.create_instance( 'img1', :name=>'TestInstance', :hardware_profile => 'm1-large' )
      instance.wont_be_nil
      instance.uri.must_match %r{#{API_URL}/instances/inst[0-9]+}
      instance.id.must_match /inst[0-9]+/
      instance.name.must_equal 'TestInstance'
      instance.image.id.must_equal 'img1'
      instance.hardware_profile.id.must_equal 'm1-large'
      instance.realm.id.must_equal 'us'
    end
  end

  it "should allow creation of new instances with specific realm" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.create_instance( 'img1', :realm=>'eu', :hardware_profile => 'm1-large' )
      instance.wont_be_nil
      instance.uri.must_match %r{#{API_URL}/instances/inst[0-9]+}
      instance.id.must_match  /inst[0-9]+/
      instance.image.id.must_equal 'img1'
      instance.hardware_profile.id.must_equal 'm1-large'
      instance.realm.id.must_equal 'eu'
    end
  end

  it "should allow creation of new instances with specific hardware profile" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.create_instance( 'img1',
                                         :hardware_profile=>'m1-xlarge' )
      instance.wont_be_nil
      instance.uri.must_match  %r{#{API_URL}/instances/inst[0-9]+}
      instance.id.must_match  /inst[0-9]+/
      instance.image.id.must_equal 'img1'
      instance.hardware_profile.id.must_equal 'm1-xlarge'
      instance.realm.id.must_equal 'us'
    end
  end

  it "should allow creation of new instances with specific hardware profile overriding memory" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      hwp = { :id => 'm1-xlarge', :memory => 32768 }
      instance = client.create_instance( 'img1', :hardware_profile=> hwp )
      instance.wont_be_nil
      instance.uri.must_match  %r{#{API_URL}/instances/inst[0-9]+}
      instance.id.must_match  /inst[0-9]+/
      instance.image.id.must_equal 'img1'
      instance.hardware_profile.id.must_equal 'm1-xlarge'
      instance.hardware_profile.memory.value.must_equal'12288'
      instance.realm.id.must_equal 'us'
    end
  end

  it "should allow creation of new instances with specific realm and hardware profile" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.create_instance( 'img1', :realm=>'eu',
                                         :hardware_profile=>'m1-xlarge' )
      instance.wont_be_nil
      instance.uri.must_match  %r{#{API_URL}/instances/inst[0-9]+}
      instance.id.must_match  /inst[0-9]+/
      instance.image.id.must_equal 'img1'
      instance.hardware_profile.id.must_equal 'm1-xlarge'
      instance.realm.id.must_equal 'eu'
    end
  end

  it "should allow fetching of instances by id" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.instance( 'inst1' )
      instance.wont_be_nil
      instance.uri.wont_be_nil
      instance.uri.must_be_kind_of String
    end
  end

  it "should allow fetching of instances by URI" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance = client.fetch_instance( API_URL + '/instances/inst1' )
      instance.wont_be_nil
      instance.uri.must_equal API_URL + '/instances/inst1'
      instance.id.must_equal 'inst1'
    end
  end

  describe "performing actions on instances" do
    it "should allow actions that are valid" do
      DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
        instance = client.instance( 'inst1' )
        instance.wont_be_nil
        instance.state.must_equal "RUNNING"
        instance.uri.must_equal API_URL + '/instances/inst1'
        instance.id.must_equal 'inst1'
        instance.stop!
        instance.state.must_equal "STOPPED"
        instance.start!
        instance.state.must_equal "RUNNING"
      end
    end

    it "should not allow actions that are invalid" do
      DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
        instance = client.instance( 'inst1' )
        instance.wont_be_nil
        unless instance.state.eql?("RUNNING")
          instance.start!
        end
        instance.state.must_equal "RUNNING"
        lambda{instance.start!}.must_raise NoMethodError
      end
    end

    it "should not throw exception when destroying an instance" do
      DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
        instance = client.create_instance( 'img1',
                                           :name=>'TestDestroyInstance',
                                           :hardware_profile => 'm1-xlarge' )
        instance.stop!
        instance.destroy!.must_be_nil
      end
    end
  end
end
