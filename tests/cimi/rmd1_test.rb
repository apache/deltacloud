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

$:.unshift File.join(File.dirname(__FILE__))

require "test_helper.rb"

class ResourceMetadataCollection < CIMI::Test::Spec
  RESOURCE_URI =
    "http://schemas.dmtf.org/cimi/1/ResourceMetadataCollection"
  ROOTS = ["resourceMetadata"]

  #  Ensure test executes in test plan order
  i_suck_and_my_tests_are_order_dependent!

  # 1.1: Query the CEP
  model :subject, :cache => true do |fmt|
    cep(:accept => fmt)
  end

  # This test must adhere to one of the "Query the CEP" test in the previous section.
  query_the_cep(ROOTS)

  it "should contain at least one Resource Metadata resource" do
      r =  ROOTS[0].underscore.to_sym
      model = fetch(subject.send(r).href)
      log.info(model.attribute_values[r][0])
      unless !model.attribute_values[r][0].nil?()
        puts "No ResourceMetadata resource available - ending test."
        return
    end
  end

  # 1.2:  Query the resource_metadata collection
  cep_json = cep(:accept => :json)

  model :resource_metadata do |fmt|
    get cep_json.json[ROOTS[0]]["href"], :accept => fmt
  end

  it "should have a response code equal to 200" do
    last_response.code.must_equal 200
  end

  it "should have a response header" do
    last_response.content_type.must_be_one_of CONTENT_TYPES.values
  end

  it "should have an id equal to the URL of the resource metadata collection" do
    resource_metadata.id.must_equal cep_json.json[ROOTS[0]]["href"]
  end

  it "should have a resourceURI set to point to ResourceMetadataCollection", :only => :json do
    last_response.json["resourceURI"].must_equal RESOURCE_URI
  end

  it "should have a count value that matches the number of ResourceMetadata elements", :only => :json do
    last_response.json["count"].must_equal last_response.json["resourceMetadata"].size()
  end

  it "should list ResourceMetadata elements", :only => :json do
    $i=0
    while $i < last_response.json["resourceMetadata"].size()
      log.info(last_response.json["resourceMetadata"][$i]["id"])
      last_response.json["resourceMetadata"][$i]["id"].wont_be_empty
      $i +=1
    end
  end

  # For each collection appearing in the CEP there should be a
  # ResourceMetadata entry with the corresponding typeURI in the ResourceMetadata collection

  it "should include at least one of capabilities/attributes/actions", :only => :json do
    rmd_type = ["capabilities", "attributes", "actions"]
    (rmd_type.any? { |rmd| last_response.json.to_s().include? rmd }).must_equal true
  end

 end
