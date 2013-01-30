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

class MachinesResourceMetadata < CIMI::Test::Spec
  RESOURCE_URI =
  "http://schemas.dmtf.org/cimi/1/Machine"
  ROOTS = ["machine", "resourceMetadata"]

  #  Ensure test executes in test plan order
  i_suck_and_my_tests_are_order_dependent!

  # This test applies only if the CEP.machines collection is present
  # and the CEP.ResourceMetadata collection contains an entry corresponding
  # to the Machine resource

  # Query the cep
  model :subject, :cache => true do |fmt|
    cep(:accept => fmt)
  end

  query_the_cep(ROOTS)

  it "should contain at least one entry corresponding to the Machine resource" do
    model = fetch(subject.send(ROOTS[1].underscore.to_sym).href)
    log.info(model.attribute_values[ROOTS[1].underscore.to_sym].to_s())
    model.attribute_values[ROOTS[1].underscore.to_sym].to_s().must_include "Machine"
  end

  # 2.1:  Query the resource_metadata collection
  cep_json = cep(:accept => :json)
  rmd_coll = get cep_json.json[ROOTS[1]]["href"], :accept => :json
  machine_index = rmd_coll.json["resourceMetadata"].index {|rmd| rmd.to_s().include? "Machine"}

  # Find the resource_metadata element that corresponds to the machine collection
  model :resource_metadata do |fmt|
    get cep_json.json[ROOTS[1]]["href"], :accept => fmt
  end

  it "should have a response code equal to 200" do
    resource_metadata
    last_response.code.must_equal 200
  end

  it "should have a ResourceMetadata.id", :only => :json do
    resource_metadata
    last_response.json["resourceMetadata"][machine_index]["id"].wont_be_nil
    last_response.json["resourceMetadata"][machine_index]["id"].to_s().must_include cep_json.json[ROOTS[1]]["href"]
    last_response.json["resourceMetadata"][machine_index]["id"].to_s().must_include ROOTS[0]
  end

  it "should have a name set to Machine", :only => :json do
    resource_metadata
    last_response.json["resourceMetadata"][machine_index]["name"].must_equal "Machine"
  end

  it "should have a typeUri set to point to Machine", :only => :json do
    resource_metadata
    last_response.json["resourceMetadata"][machine_index]["typeUri"].must_equal RESOURCE_URI
  end

  it "should list at least one of capabilities/attributes/actions", :only => :json do
    rmd_type = ["capabilities", "attributes", "actions"]
    resource_metadata
    (rmd_type.any? { |rmd| last_response.json["resourceMetadata"][machine_index].to_s().include? rmd }).must_equal true
  end

  # 2.2: Query the ResourceMetadata entry
  model :resource_metadata_machine do |fmt|
    get rmd_coll.json["resourceMetadata"][machine_index]["id"], :accept => fmt
  end

  it "should have a response code equal to 200" do
    resource_metadata_machine
    last_response.code.must_equal 200
  end

  it "should show each capability, attribute and action containing attributes specified", :only => :json do
    resource_metadata_machine
    rmd_type = ["capabilities", "attributes", "actions"]
    elements = [ ["name", "uri", "description", "value"],
      # see Mantis issue 1977
      ["name", "namespace", "type", "required"],  # "constraints"],
      ["name", "uri", "description", "method", "inputMessage", "outputMessage"] ]
    $i=0
    while $i < rmd_type.size()
      unless last_response.json[rmd_type[$i]].nil?()
        log.info("Testing resource metadata: " + last_response.json[rmd_type[$i]].to_s())
        log.info(" For elements: " + elements[$i].to_s())
        (elements[$i].all? { |element| last_response.json[rmd_type[$i]].all? {|i| !i[element].nil?()} }).must_equal true
        log.info(" Results for " + rmd_type[$i] + ":  true")
      end
      $i +=1
    end
  end

end
