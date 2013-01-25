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

$:.unshift File.join(File.dirname(__FILE__), '..')
require "deltacloud/test_setup.rb"

BUCKETS = "/buckets"

def small_blob_file
 File.new(File::join(File::dirname(__FILE__),"test_blob_small.png"))
end

def large_blob_file
 File.new(File::join(File::dirname(__FILE__),"test_blob_large.png"))
end


describe 'Deltacloud API buckets collection' do

  include Deltacloud::Test::Methods

  need_collection :buckets

  #make sure we have at least one bucket and blob to test

  if collection_supported :buckets
    @@my_bucket = random_name
    @@my_blob = random_name
    res = post(BUCKETS, :name=>@@my_bucket)
    unless res.code == 201
      raise Exception.new("Failed to create bucket #{@@my_bucket}")
    end

    res = put("#{BUCKETS}/#{@@my_bucket}/#{@@my_blob}", "This is the test blob content",
           {:content_type=>"text/plain", "X-Deltacloud-Blobmeta-Version"=>"1.0",
            "X-Deltacloud-Blobmeta-Author"=>"herpyderp"})
    unless res.code == 200
      raise Exception.new("Failed to create blob #{@@my_blob}")
    end
  end

  # delete the bucket/blob we created for the tests
  MiniTest::Unit.after_tests {
    res = delete("/buckets/#{@@my_bucket}/#{@@my_blob}")
    unless res.code == 204
      raise Exception.new("Failed to delete blob #{@@my_blob}")
    end
    res = delete("/buckets/#{@@my_bucket}")
    unless res.code == 204
      raise Exception.new("Failed to delete bucket #{@@my_bucket}")
    end
  }

  #Run the 'common' tests for all collections defined in common_tests_collections.rb
  CommonCollectionsTest::run_collection_and_member_tests_for("buckets")

  #Now run the bucket-specific tests:
  it 'must have the "size" element defined for each bucket in collection' do
    #extra check - make sure at least the bucket we created is tested
    tested_my_bucket = false
    res = get(BUCKETS)
    (res.xml/'buckets/bucket').each do |buk|
      tested_my_bucket = true if buk[:id] == @@my_bucket
      (buk/'size').wont_be_nil
      (buk/'size').wont_be_empty
    end
    tested_my_bucket.must_equal true
  end

  it 'all "blob" elements for the bucket should match the ones in collection' do
    #extra check - make sure at least the bucket+blob we created are tested
    tested_my_bucket = tested_my_blob = false
    res = get(BUCKETS)
    (res.xml/'buckets/bucket').each do |buk|
      tested_my_bucket = true if buk[:id] == @@my_bucket
      bucket = get(BUCKETS+"/#{buk[:id]}")
      (bucket.xml/'bucket/blob').each do |blob|
        tested_my_blob = true if blob[:id] == @@my_blob
        blob[:id].wont_be_nil
        blob[:href].wont_be_nil
        blob[:href].must_match /^http/
        blob[:href].must_match /#{buk[:id]}\/#{blob[:id]}$/
      end
    end
    (tested_my_bucket.must_equal tested_my_blob).must_equal true
  end

  it 'must allow to get all blobs details and the details should be set correctly' do
    #extra check - make sure at least the bucket+blob we created are tested
    tested_my_bucket = tested_my_blob = false
    res = get(BUCKETS)
    (res.xml/'buckets/bucket').each do |buk|
      tested_my_bucket = true if buk[:id] == @@my_bucket
      bucket = get(BUCKETS+"/#{buk[:id]}")
      (bucket.xml/'bucket/blob').each do |bl|
        blob = get(BUCKETS+"/#{buk[:id]}/#{bl[:id]}")
        tested_my_blob = true if bl[:id] == @@my_blob
        blob.xml.root.name.must_equal 'blob'
        blob.xml.root[:id].must_equal bl[:id]
        (blob.xml/'bucket').wont_be_empty
        (blob.xml/'bucket').size.must_equal 1
        (blob.xml/'bucket').first.text.wont_be_nil
        (blob.xml/'bucket').first.text.must_equal buk[:id]
        (blob.xml/'content_length').wont_be_empty
        (blob.xml/'content_length').size.must_equal 1
        (blob.xml/'content_length').first.text.must_match /^(\d+)$/
        (blob.xml/'content_type').wont_be_empty
        (blob.xml/'content_type').size.must_equal 1
        (blob.xml/'content_type').first.text.wont_be_nil
        (blob.xml/'last_modified').wont_be_empty
        (blob.xml/'last_modified').size.must_equal 1
        (blob.xml/'last_modified').first.text.wont_be_empty
        (blob.xml/'content').wont_be_empty
        (blob.xml/'content').size.must_equal 1
        (blob.xml/'content').first[:rel].wont_be_nil
        (blob.xml/'content').first[:rel].must_equal 'blob_content'
        (blob.xml/'content').first[:href].wont_be_nil
        (blob.xml/'content').first[:href].must_match /^http/
        (blob.xml/'content').first[:href].must_match /\/content$/
      end
    end
    (tested_my_bucket.must_equal tested_my_blob).must_equal true
  end

  it 'should be possible to create bucket with POST /api/buckets and delete it with DELETE /api/buckets/:id' do
    bucket_name = random_name
    #create bucket
    res = post(BUCKETS, :name=>bucket_name)
    #check response
    res.code.must_equal 201
    res.xml.xpath("//bucket/name").text.must_equal bucket_name
    res.xml.xpath("//bucket").size.must_equal 1
    res.xml.xpath("//bucket")[0][:id].must_equal bucket_name
    #GET bucket
    res = get(BUCKETS+"/"+bucket_name)
    res.code.must_equal 200
    #DELETE bucket
    res = delete(BUCKETS+"/"+bucket_name)
    res.code.must_equal 204
  end

  it 'should be possible to create large blob with PUT /api/buckets/:id/blob_id (STREAM)' do
    skip "Streaming PUT for blobs not supported by driver #{api.driver} currently running at #{api.url}" if api.driver == "mock"
    blob_name = random_name
    #using @@my_bucket which we know exists
    res = put("#{BUCKETS}/#{@@my_bucket}/#{blob_name}", large_blob_file,
           {:content_type=>"image/png", "X-Deltacloud-Blobmeta-Createdfor"=>"putblobtest",
            "X-Deltacloud-Blobmeta-Author"=>"herpyderp", "X-Deltacloud-Blobmeta-Type"=>"largeblob"})
    res.code.must_equal 200
    #GET it
    res = get(BUCKETS+"/"+@@my_bucket+"/"+blob_name)
    res.code.must_equal 200
    #delete it:
    res = delete("/buckets/#{@@my_bucket}/#{blob_name}")
    res.code.must_equal 204
  end

  it 'should be possible to create small blob with PUT /api/buckets/:id/blob_id (NO STREAM)' do
    blob_name = random_name
    #using @@my_bucket which we know exists
    res = put("#{BUCKETS}/#{@@my_bucket}/#{blob_name}", small_blob_file,
           {:content_type=>"image/png", "X-Deltacloud-Blobmeta-Createdfor"=>"putblobtest",
            "X-Deltacloud-Blobmeta-Author"=>"herpyderp", "X-Deltacloud-Blobmeta-Type"=>"smallbob"})
    res.code.must_equal 200
    #GET it
    res = get(BUCKETS+"/"+@@my_bucket+"/"+blob_name)
    res.code.must_equal 200
    #delete it:
    res = delete("/buckets/#{@@my_bucket}/#{blob_name}")
    res.code.must_equal 204
  end

  it 'should be possible to create blob with POST /api/buckets/:id' do
    blob_name = random_name
    res = post("#{BUCKETS}/#{@@my_bucket}", {:blob_id => blob_name, :blob_data => small_blob_file, :multipart => true, :meta_params => 2, :meta_name1=>"Author", :meta_value1 => "herpyderp", :meta_name2 => "Type", :meta_value2 => "formPostedBlob"})
    res.code.must_equal 201
    #GET it
    res = get(BUCKETS+"/"+@@my_bucket+"/"+blob_name)
    res.code.must_equal 200
    #delete it:
    res = delete("/buckets/#{@@my_bucket}/#{blob_name}")
    res.code.must_equal 204
  end

  it 'should be possible to get blob metadata with HEAD /api/buckets/:id/blob_id' do
    res = head("#{BUCKETS}/#{@@my_bucket}/#{@@my_blob}")
    res.code.must_equal 204
    res.headers.keys.must_include :x_deltacloud_blobmeta_version
    res.headers.keys.must_include :x_deltacloud_blobmeta_author
  end

  it 'should be possible to update blob metadata with POST /api/buckets/:id/blob' do
    res = post("#{BUCKETS}/#{@@my_bucket}/#{@@my_blob}", "", {"X-Deltacloud-Blobmeta-Version"=>"2.5",
               "X-Deltacloud-Blobmeta-Author"=>"derpyherpy", "X-Deltacloud-Blobmeta-Updated"=>"true"})
    res.code.must_equal 204
    res.headers.keys.must_include :x_deltacloud_blobmeta_version
    res.headers.keys.must_include :x_deltacloud_blobmeta_author
    res.headers.keys.must_include :x_deltacloud_blobmeta_updated
  end

  it 'should be possible to GET blob data with GET /api/buckets/:id/blob/content' do
    res = get("#{BUCKETS}/#{@@my_bucket}/#{@@my_blob}/content")
    res.code.must_equal 200
    res.must_equal "This is the test blob content"
  end

  describe "with feature bucket_location" do
    need_feature :buckets, :bucket_location

    it 'should be possible to specify location for POST /api/buckets if bucket_location feature' do
      bucket_name = random_name
      location = api.bucket_locations.choice #random element
      raise Exception.new("Unable to get location constraint from config.yaml for driver #{api.driver} - check configuration") unless location
      res = post(BUCKETS, {:name=>bucket_name, :bucket_location=>location})
      res.code.must_equal 201
      res.xml.xpath("//bucket/name").text.must_equal bucket_name
      res.xml.xpath("//bucket").size.must_equal 1
      res.xml.xpath("//bucket")[0][:id].must_equal bucket_name
      #GET bucket
      res = get(BUCKETS+"/"+bucket_name)
      res.code.must_equal 200
      #DELETE bucket
      res = delete(BUCKETS+"/"+bucket_name)
      res.code.must_equal 204
    end
  end

end
