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

require 'rubygems'
require 'require_relative' if RUBY_VERSION =~ /^1\.8/

require_relative './test_helper.rb'

describe "Images" do

  it "should allow retrieval of all images" do
    [API_URL, API_URL_REDIRECT].each do |entry_point|
      DeltaCloud.new( API_NAME, API_PASSWORD, entry_point ) do |client|
        images = client.images
        images.wont_be_empty
        images.size.must_equal 3
        images.each do |image|
          image.uri.wont_be_nil
          image.uri.must_be_kind_of String
          image.description.wont_be_nil
          image.description.must_be_kind_of String
          image.architecture.wont_be_nil
          image.architecture.must_be_kind_of String
          image.owner_id.wont_be_nil
          image.owner_id.must_be_kind_of String
        end
      end
    end
  end

  it "should allow retrieval of my own images" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      images = client.images( :owner_id=>:self )
      images.wont_be_empty
      images.size.must_equal 1
      images.each do |image|
        image.uri.wont_be_nil
        image.uri.must_be_kind_of String
        image.description.wont_be_nil
        image.description.must_be_kind_of String
        image.architecture.wont_be_nil
        image.architecture.must_be_kind_of String
        image.owner_id.wont_be_nil
        image.owner_id.must_be_kind_of String
      end
    end
  end

  it "should allow retrieval of a single image by ID" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      image = client.image( 'img1' )
      image.wont_be_nil
      image.uri.must_equal API_URL + '/images/img1'
      image.id.must_equal 'img1'
      image.architecture.must_equal 'x86_64'
    end
  end

  it "should allow retrieval of a single image by URI" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      image = client.fetch_image( API_URL + '/images/img1' )
      image.wont_be_nil
      image.uri.must_equal API_URL + '/images/img1'
      image.id.must_equal 'img1'
      image.architecture.must_equal 'x86_64'
    end
  end

  describe "filtering by architecture" do
    it "return matching images" do
      DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
        images = client.images( :architecture=>'x86_64' )
        images.wont_be_empty
        images.each do |image|
          image.architecture.must_equal 'x86_64'
        end
        images = client.images( :architecture=>'i386' )
        images.wont_be_empty
        images.each do |image|
          image.architecture.must_equal 'i386'
        end
      end
    end

    it "should return an empty array for no matches" do
      DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
        images = client.images( :architecture=>'8088' )
        images.must_be_empty
      end
    end
  end
end
