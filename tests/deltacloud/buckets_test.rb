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


require 'ruby-debug'
BUCKETS = "/buckets"

#make sure we have at least one bucket and blob to test
bucket, blob = create_a_bucket_and_blob

features_hash = discover_features

describe 'Deltacloud API buckets collection' do

  MiniTest::Unit.after_tests{
    #finally delete the bucket/blob we created for the tests:
    delete_bucket_and_blob(bucket, blob)
  }

  it 'must advertise the buckets collection in API entrypoint' do
    res = xml_response(get("/"))
    (res/'api/link[@rel=buckets]').wont_be_empty
  end

  it 'must require authentication to access the "bucket" collection' do
    proc {  get(BUCKETS, :noauth => true) }.must_raise RestClient::Request::Unauthorized
  end

  it 'should respond with HTTP_OK when accessing the :buckets collection with authentication' do
    res = get(BUCKETS)
    res.code.must_equal 200
  end

  it 'should be possible to create bucket with POST /api/buckets and delete it with DELETE /api/buckets/:id' do
    bucket_name = random_name
    #create bucket
    res = post(BUCKETS, :name=>bucket_name)
    #check response
    res.code.must_equal 201
    xml_res = xml_response(res)
    xml_res.xpath("//bucket/name").text.must_equal bucket_name
    xml_res.xpath("//bucket").size.must_equal 1
    xml_res.xpath("//bucket")[0][:id].must_equal bucket_name
    #GET bucket
    res = get(BUCKETS+"/"+bucket_name)
    res.code.must_equal 200
    #DELETE bucket
    res = delete(BUCKETS+"/"+bucket_name)
    res.code.must_equal 204
  end

  it 'should be possible to specify location for POST /api/buckets if bucket_location feature' do
    skip("No bucket_location feature specified for driver #{API_DRIVER} running at #{API_URL}... skipping test") unless features_hash["buckets"].include?("bucket_location")
    bucket_name = random_name
    #    res = post({:name=>bucket_name, :bucket_location=>
  end


  it 'should support the JSON media type' do
    res = get(BUCKETS, :accept=>:json)
    res.code.must_equal 200
    res.headers[:content_type].must_equal 'application/json'
    assert_silent {JSON.parse(res)}
  end

  it 'must include the ETag in HTTP headers' do
    res = get(BUCKETS)
    res.headers[:etag].wont_be_nil
  end

  it 'must have the "buckets" element on top level' do
    xml_res = xml_response(get(BUCKETS, :accept=>:xml))
    xml_res.root.name.must_equal 'buckets'
  end

  it 'must have some "bucket" elements inside "buckets"' do
    xml_res = xml_response(get(BUCKETS, :accept=>:xml))
    (xml_res/'buckets/bucket').wont_be_empty
  end

  it 'must provide the :id attribute for each bucket in collection' do
    xml_res = xml_response(get(BUCKETS, :accept=>:xml))
    (xml_res/'buckets/bucket').each do |r|
      r[:id].wont_be_nil
    end
  end

  it 'must include the :href attribute for each "bucket" element in collection' do
    xml_res = xml_response(get(BUCKETS, :accept=>:xml))
    (xml_res/'buckets/bucket').each do |r|
      r[:href].wont_be_nil
    end
  end

  it 'must use the absolute URL in each :href attribute' do
    xml_res = xml_response(get(BUCKETS, :accept=>:xml))
    (xml_res/'buckets/bucket').each do |r|
      r[:href].must_match /^http/
    end
  end

  it 'must have the URL ending with the :id of the bucket' do
    xml_res = xml_response(get(BUCKETS, :accept=>:xml))
    (xml_res/'buckets/bucket').each do |r|
      r[:href].must_match /#{r[:id]}$/
    end
  end

  it 'must have the "name" element defined for each bucket in collection' do
    xml_res = xml_response(get(BUCKETS, :accept => :xml))
    (xml_res/'buckets/bucket').each do |r|
      (r/'name').wont_be_nil
      (r/'name').wont_be_empty
    end
  end

  it 'must have the "size" element defined for each bucket in collection' do
    xml_res = xml_response(get(BUCKETS, :accept => :xml))
    (xml_res/'buckets/bucket').each do |r|
      (r/'size').wont_be_nil
      (r/'size').wont_be_empty
    end
  end

  it 'must return 200 OK when following the URL in bucket element' do
    xml_res = xml_response(get(BUCKETS, :accept => :xml))
    (xml_res/'buckets/bucket').each do |r|
      bucket_res = get r[:href]
      bucket_res.code.must_equal 200
    end
  end

  it 'must have the "name" element for the bucket and it should match with the one in collection' do
    xml_res = xml_response(get(BUCKETS, :accept => :xml))
    (xml_res/'buckets/bucket').each do |r|
      bucket_xml = xml_response(get(BUCKETS+"/#{r[:id]}", :accept=>:xml))
      (bucket_xml/'name').wont_be_empty
      (bucket_xml/'name').first.text.must_equal((r/'name').first.text)
    end
  end

  it 'all "blob" elements for the bucket should match the ones in collection' do
    xml_res = xml_response(get(BUCKETS, :accept => :xml))
    (xml_res/'buckets/bucket').each do |r|
      bucket_xml = xml_response(get(BUCKETS+"/#{r[:id]}", :accept=>:xml))
      (bucket_xml/'bucket/blob').each do |b|
        b[:id].wont_be_nil
        b[:href].wont_be_nil
        b[:href].must_match /^http/
        b[:href].must_match /#{r[:id]}\/#{b[:id]}$/
      end
    end
  end

  it 'must allow to get all blobs details and the details should be set correctly' do
    xml_res = xml_response(get(BUCKETS, :accept => :xml))
    (xml_res/'buckets/bucket').each do |r|
      bucket_xml = xml_response(get(BUCKETS+"/#{r[:id]}", :accept=>:xml))
      (bucket_xml/'bucket/blob').each do |b|
        blob_xml = xml_response(get(BUCKETS+"/#{r[:id]}/#{b[:id]}", :accept=>:xml))
        blob_xml.root.name.must_equal 'blob'
        blob_xml.root[:id].must_equal b[:id]
        (blob_xml/'bucket').wont_be_empty
        (blob_xml/'bucket').size.must_equal 1
        (blob_xml/'bucket').first.text.wont_be_nil
        (blob_xml/'bucket').first.text.must_equal r[:id]
        (blob_xml/'content_length').wont_be_empty
        (blob_xml/'content_length').size.must_equal 1
        (blob_xml/'content_length').first.text.must_match /^(\d+)$/
        (blob_xml/'content_type').wont_be_empty
        (blob_xml/'content_type').size.must_equal 1
        (blob_xml/'content_type').first.text.wont_be_nil
        (blob_xml/'last_modified').wont_be_empty
        (blob_xml/'last_modified').size.must_equal 1
        (blob_xml/'last_modified').first.text.wont_be_empty
        (blob_xml/'content').wont_be_empty
        (blob_xml/'content').size.must_equal 1
        (blob_xml/'content').first[:rel].wont_be_nil
        (blob_xml/'content').first[:rel].must_equal 'blob_content'
        (blob_xml/'content').first[:href].wont_be_nil
        (blob_xml/'content').first[:href].must_match /^http/
        (blob_xml/'content').first[:href].must_match /\/content$/
      end
    end
  end

end
