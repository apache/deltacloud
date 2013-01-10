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

def prop_check(prop, value_class)
  if prop.present?
    prop.value.wont_be_nil
    prop.value.must_be_kind_of value_class
  end
end

describe "Hardware Profiles" do

  it "should allow retrieval of all hardware profiles" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      hardware_profiles = client.hardware_profiles
      hardware_profiles.wont_be_empty
      hardware_profiles.each do |hwp|
        hwp.uri.wont_be_nil
        hwp.uri.must_be_kind_of String
        prop_check(hwp.architecture, String) unless hwp.name.eql?("opaque")
     end
    end
  end

  it "should allow filtering of hardware_profiles by architecture" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      hardware_profiles = client.hardware_profiles( :architecture=>'i386' )
      hardware_profiles.wont_be_empty
      hardware_profiles.size.must_equal 1
      hardware_profiles.first.architecture.value.must_equal 'i386'
    end
  end

  it "should allow fetching a hardware_profile by id" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      hwp = client.hardware_profile( 'm1-small' )
      hwp.wont_be_nil
      hwp.id.must_equal 'm1-small'
    end
  end

  it "should allow fetching different hardware_profiles" do
    client = DeltaCloud.new( API_NAME, API_PASSWORD, API_URL )
    hwp1 = client.hardware_profile( 'm1-small' )
    hwp2 = client.hardware_profile( 'm1-large' )
    hwp1.storage.value.wont_equal hwp2.storage.value
    hwp1.memory.value.wont_equal hwp2.memory.value
  end

  it "should allow fetching a hardware_profile by URI" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      hwp = client.fetch_hardware_profile( API_URL + '/hardware_profiles/m1-small' )
      hwp.wont_be_nil
      hwp.id.must_equal 'm1-small'
    end
  end

end
