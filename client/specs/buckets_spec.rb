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

require 'specs/spec_helper'

describe "buckets" do

  it_should_behave_like "all resources"

  it "should allow retrieval of all buckets" do
    [API_URL, API_URL_REDIRECT].each do |entry_point|
      DeltaCloud.new( API_NAME, API_PASSWORD, entry_point ) do |client|
        buckets = client.buckets
        buckets.should_not be_empty
        buckets.each do |bucket|
          bucket.uri.should_not be_nil
          bucket.uri.should be_a( String )
          bucket.name.should_not be_nil
          bucket.name.should be_a(String)
        end
      end
    end
  end

  it "should allow retrieval of a named bucket" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      bucket = client.bucket("bucket1")
      bucket.should_not be_nil
      bucket.uri.should eql(API_URL + "/buckets/bucket1")
      bucket.size.should eql(3.0)
      bucket.name.should_not be_nil
      bucket.name.should be_a(String)
      blob_list = bucket.blob_list.split(", ")
      blob_list.size.should eql(bucket.size.to_i)
    end
  end

end

describe "Operations on buckets" do

  it "should allow creation of a new bucket" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      new_bucket = client.create_bucket({'id' => "my_new_bucket"})
      new_bucket.should_not be_nil
      new_bucket.uri.should eql(API_URL + "/buckets/my_new_bucket")
      new_bucket.name.should_not be_nil
      new_bucket.name.should be_a(String)
      new_bucket.name.should eql("my_new_bucket")
    end
  end

  it "should allow deletion of an existing bucket" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      new_bucket = client.bucket("my_new_bucket")
      new_bucket.should_not be_nil
      new_bucket.name.should eql("my_new_bucket")
      lambda{
              client.destroy_bucket({'id' => "my_new_bucket"})
            }.should_not raise_error
    end
  end

  it "should throw error if you delete a non existing bucket" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      lambda{
              client.destroy_bucket({'id' => "i_dont_exist"})
            }.should raise_error
    end
  end

end

describe "Blobs" do

  it "should allow retrieval of a bucket's blobs" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      bucket = client.bucket("bucket1")
      bucket.should_not be_nil
      blob_list = bucket.blob_list.split(", ")
      blob_list.size.should eql(bucket.size.to_i)
      blob_list.each do |b_id|
        blob = client.blob({"bucket" => bucket.name, :id => b_id})
        puts blob.inspect
        blob.bucket.should_not be_nil
        blob.bucket.should be_a(String)
        blob.bucket.should eql(bucket.name)
        blob.content_length.should_not be_nil
        blob.content_length.should be_a(Float)
        blob.content_length.should >= 0
        blob_data = client.blob_data({"bucket" => bucket.name, :id => b_id})
        blob_data.size.to_f.should == blob.content_length
        blob.last_modified.should_not be_nil
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
      some_new_blob = client.create_blob({:id => "some_new_blob",
                          'bucket' => "bucket1",
                          'file_path' => blob_data.path})
      some_new_blob.should_not be_nil
      some_new_blob.content_length.should_not be_nil
      some_new_blob.content_length.should eql(24.0)
      File.delete(blob_data.path)
    end
  end

  it "should allow deletion of an existing blob" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      lambda{
              client.destroy_blob({:id=>"some_new_blob", 'bucket'=>"bucket1"})
            }.should_not raise_error
    end
  end

  it "should throw error if you delete a non existing blob" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      lambda{
              client.destroy_blob({:id=>"no_such_blob", 'bucket'=>"bucket1"})
            }.should raise_error
    end
  end
end
