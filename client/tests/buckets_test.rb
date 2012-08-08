#
# Copyright (C) 2009-2011  Red Hat, Inc.
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

describe "Buckets" do

  it "should allow retrieval of all buckets" do
    [API_URL, API_URL_REDIRECT].each do |entry_point|
      DeltaCloud.new( API_NAME, API_PASSWORD, entry_point ) do |client|
        buckets = client.buckets
        buckets.wont_be_empty
        buckets.each do |bucket|
          bucket.uri.wont_be_nil
          bucket.uri.must_be_kind_of String
          bucket.name.wont_be_nil
          bucket.name.must_be_kind_of String
        end
      end
    end
  end

  it "should allow retrieval of a named bucket" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      bucket = client.bucket("bucket1")
      bucket.wont_be_nil
      bucket.uri.must_equal API_URL + "/buckets/bucket1"
      bucket.size.must_equal 3.0
      bucket.name.wont_be_nil
      bucket.name.must_be_kind_of String
      blob_list = bucket.blob_list.split(", ")
      blob_list.size.must_equal bucket.size.to_i
    end
  end

end

describe "Operations on buckets" do

  it "should allow creation of a new bucket" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      new_bucket = client.create_bucket({'id' => "my_new_bucket"})
      new_bucket.wont_be_nil
      new_bucket.uri.must_equal API_URL + "/buckets/my_new_bucket"
      new_bucket.name.wont_be_nil
      new_bucket.name.must_be_kind_of String
      new_bucket.name.must_equal "my_new_bucket"
    end
  end

  it "should allow deletion of an existing bucket" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      new_bucket = client.bucket("my_new_bucket")
      new_bucket.wont_be_nil
      new_bucket.name.must_equal "my_new_bucket"
      client.destroy_bucket('id' => "my_new_bucket").must_be_nil
    end
  end

  it "should throw error if you delete a non existing bucket" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      lambda {
      client.destroy_bucket({'id' => "i_dont_exist"}).must_be_nil
      }.must_raise DeltaCloud::HTTPError::DeltacloudError
    end
  end

end

describe "Blobs" do

  it "should allow retrieval of a bucket's blobs" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      bucket = client.bucket("bucket1")
      bucket.wont_be_nil
      blob_list = bucket.blob_list.split(", ")
      blob_list.size.must_equal bucket.size.to_i
      blob_list.each do |b_id|
        blob = client.blob("bucket" => bucket.name, :id => b_id)
        blob.bucket.wont_be_nil
        blob.bucket.must_be_kind_of String
        blob.bucket.must_equal bucket.name
        blob.content_length.wont_be_nil
        blob.content_length.must_be_kind_of Float
        blob.content_length.must_be :'>=', 0
        blob_data = client.blob_data("bucket" => bucket.name, :id => b_id)
        blob_data.size.to_f.must_equal blob.content_length
        blob.last_modified.wont_be_nil
      end
    end
  end

end

describe "Operations on blobs" do

  it "should successfully create a new blob" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      blob_data = File.new("./blob_data_file", "w+")
      blob_data.write("this is some blob data \n")
      blob_data.rewind
      some_new_blob = client.create_blob(
        :id => "some_new_blob",
        'bucket' => "bucket1",
        'file_path' => blob_data.path
      )
      some_new_blob.wont_be_nil
      some_new_blob.content_length.wont_be_nil
      some_new_blob.content_length.must_equal 24.0
      File.delete(blob_data.path)
    end
  end

  it "should allow deletion of an existing blob" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      client.destroy_blob(:id=>"some_new_blob", 'bucket'=>"bucket1").must_be_nil
    end
  end

  it "should throw error if you delete a non existing blob" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      lambda {
        client.destroy_blob(:id=>"no_such_blob", 'bucket'=>"bucket1").must_be_nil
      }.must_raise DeltaCloud::HTTPError::DeltacloudError
    end
  end

end
