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

IMAGES = "/images"

describe 'Deltacloud API Images collection' do
  include Deltacloud::Test::Methods

  need_collection :images

  def each_image_xml(&block)
    res = get(IMAGES)
    (res.xml/'images/image').each do |r|
      image_res = get(IMAGES + '/' + r[:id])
      yield image_res.xml
    end
  end

  #Run the 'common' tests for all collections defined in common_tests_collections.rb
  CommonCollectionsTest::run_collection_and_member_tests_for("images")

  #Now run the images-specific tests:
  it 'should have the "owner_id", "description", "architecure" and "state" element for each image' do
    each_image_xml do |image_xml|
      (image_xml/'state').wont_be_empty
      (image_xml/'owner_id').wont_be_empty
      (image_xml/'architecture').wont_be_empty
      (image_xml/'description').wont_be_empty
    end
  end

  it 'should include the list of compatible hardware_profiles for each image' do
    each_image_xml do |image_xml|
    (image_xml/'hardware_profiles/hardware_profile').wont_be_empty
      (image_xml/'hardware_profiles/hardware_profile').each do |hwp|
        hwp[:href].wont_be_nil
        hwp[:href].must_match /^http/
        hwp[:id].wont_be_nil
        hwp[:href].must_match /\/#{hwp[:id]}$/
        hwp[:rel].must_equal 'hardware_profile'
      end
    end
  end

  it 'should advertise the list of actions that can be executed for each image' do
    each_image_xml do |image_xml|
      (image_xml/'actions/link').wont_be_empty
      (image_xml/'actions/link').each do |l|
        l[:href].wont_be_nil
        l[:href].must_match /^http/
        l[:method].wont_be_nil
        l[:rel].wont_be_nil
      end
    end
  end

end
