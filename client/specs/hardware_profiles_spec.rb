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

def prop_check(prop, value_class)
  if prop.present?
    prop.value.should_not be_nil
    prop.value.should be_a(value_class)
  end
end

describe "hardware_profiles" do

  it_should_behave_like "all resources"

  it "should allow retrieval of all hardware profiles" do
    [API_URL, API_URL_REDIRECT].each do |entry_point|
      DeltaCloud.new( API_NAME, API_PASSWORD, entry_point ) do |client|
        hardware_profiles = client.hardware_profiles
        hardware_profiles.should_not be_empty
        hardware_profiles.each do |hwp|
          hwp.uri.should_not be_nil
          hwp.uri.should be_a(String)
          prop_check(hwp.architecture, String)  if hwp.architecture
        end
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

  it "should allow fetching different hardware_profiles" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    hwp1 = client.hardware_profile( 'm1-small' )
    hwp2 = client.hardware_profile( 'm1-xlarge' )
    hwp1.storage.value.should_not eql(hwp2.storage.value)
    hwp1.memory.value.should_not eql(hwp2.memory.value)
  end

  it "should allow fetching a hardware_profile by URI" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      hwp = client.fetch_hardware_profile( API_URL + '/hardware_profiles/m1-small' )
      hwp.should_not be_nil
      hwp.id.should eql( 'm1-small' )
    end
  end

end
