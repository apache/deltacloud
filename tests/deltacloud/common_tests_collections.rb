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

module CommonCollectionsTest

  #tests for only the 'top-level' collection, i.e. for 'images' but
  #not for each 'image' in 'images'
  def self.run_collection_tests_for(test_collection)
    describe "collection common tests for #{test_collection}" do

      it "must advertise the #{test_collection} collection in API entrypoint" do
        res = get("/").xml
        (res/"api/link[@rel=#{test_collection}]").wont_be_empty
      end

      it "should respond with HTTP_OK when accessing the #{test_collection} collection with authentication" do
        res = get(test_collection)
        res.code.must_equal 200
      end

      it 'should support the JSON media type' do
        res = get(test_collection, :accept=>:json)
        res.code.must_equal 200
        res.headers[:content_type].must_equal 'application/json'
        assert_silent {JSON.parse(res)}
      end

      it "must require authentication to access the #{test_collection} collection" do
        skip "Skipping for #{test_collection} as no auth required here" if ["hardware_profiles", "instance_states"].include?(test_collection)
        proc {  get(test_collection, :noauth => true) }.must_raise RestClient::Request::Unauthorized
      end

      it 'must include the ETag in HTTP headers' do
        res = get(test_collection)
        res.headers[:etag].wont_be_nil
      end

      it "must have the #{test_collection} element on top level" do
        res = get(test_collection)
        if test_collection == "instance_states"
          res.xml.root.name.must_equal "states"
        else
          res.xml.root.name.must_equal test_collection
        end
      end
    end
  end

  #run tests for both the top-level collection and it's members
  def self.run_collection_and_member_tests_for(test_collection)
    #first run only 'top-level' collection tests (e.g. for 'images')
    run_collection_tests_for(test_collection)

    #now for each member of collection (.e.g. each 'image' in 'images')
    describe "collection member common tests for #{test_collection}" do

      it "must have some #{test_collection.singularize} elements inside #{test_collection} " do
        res = get(test_collection)
        (res.xml/"#{test_collection}/#{test_collection.singularize}").wont_be_empty
      end

      it "must provide the :id attribute for each #{test_collection.singularize} in collection" do
        res = get(test_collection)
        (res.xml/"#{test_collection}/#{test_collection.singularize}").each do |r|
          r[:id].wont_be_nil
        end
      end

      it "must include the :href attribute for each #{test_collection} element in collection" do
        res = get(test_collection)
        (res.xml/"#{test_collection}/#{test_collection.singularize}").each do |r|
          r[:href].wont_be_nil
        end
      end

      it 'must use the absolute URL in each :href attribute' do
        res = get(test_collection)
        (res.xml/"#{test_collection}/#{test_collection.singularize}").each do |r|
          r[:href].must_match /^http/
        end
      end

      it "must have the URL ending with the :id of the #{test_collection.singularize}" do
        res = get(test_collection)
        (res.xml/"#{test_collection}/#{test_collection.singularize}").each do |r|
          r[:href].must_match /#{r[:id]}$/
        end
      end

      it "must have the \"name\" element defined for each #{test_collection.singularize} in collection" do
        res = get(test_collection)
        (res.xml/"#{test_collection}/#{test_collection.singularize}").each do |r|
          (r/'name').wont_be_nil
          (r/'name').wont_be_empty
        end
      end

      it "must return 200 OK when following the URL in #{test_collection.singularize} element" do
        res = get(test_collection)
        (res.xml/"#{test_collection}/#{test_collection.singularize}").each do |r|
          element_res = get r[:href]
          element_res.code.must_equal 200
        end
      end

      it "must have the \"name\" element for the #{test_collection.singularize} and it should match with the one in collection" do
        res = get(test_collection)
        (res.xml/"#{test_collection}/#{test_collection.singularize}").each do |r|
          element = get(test_collection+"/#{r[:id]}")
          (element.xml/'name').wont_be_empty
          (element.xml/'name').first.text.must_equal((r/'name').first.text)
        end
      end

    end
  end
end
