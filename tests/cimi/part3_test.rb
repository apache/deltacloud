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

class CreateNewMachineFromMachineTemplate < CIMI::Test::Spec
  RESOURCE_URI =
    "http://schemas.dmtf.org/cimi/1/CloudEntryPoint"
  ROOTS = ["machines", "machineImages", "machineConfigurations"]

  MiniTest::Unit.after_tests { teardown(@@created_resources, api.basic_auth) }

  #  Ensure test executes in test plan order
  i_suck_and_my_tests_are_order_dependent!

  model :subject, :cache => true do |fmt|
    cep(:accept => fmt)
  end

  # This test must adhere to one of the "Query the CEP" test in the previous section.
  # CEP.machines, CEP.machineConfigs and CEP.machineImages must be set
  query_the_cep(ROOTS)

  #create a machineTemplate for use in these tests:
  cep_json = cep(:accept => :json)
  mach_templ_add_uri = discover_uri_for("add", "machineTemplates")
  mach_templ_created = post(mach_templ_add_uri,
    "<MachineTemplateCreate>" +
      "<name>cimi_machineTemplate1</name>"+
      "<description>A CIMI MachineTemplate, created by part3_test.rb</description>"+
      "<property name=\"foo\">bar</property>"+
      "<machineConfig " +
        "href=\"" + get_a(cep_json, "machineConfig") + "\"/>" +
      "<machineImage " +
        "href=\"" + get_a(cep_json, "machineImage") + "\"/>" +
    "</MachineTemplateCreate>",
    :accept => :json, :content_type => :xml)

  # 3.1: Query the CEP
  model :machineTemplate  do |fmt|
    get mach_templ_created.json["id"], :accept => fmt
  end

  # This test must adhere to one of the "Query the CEP" test in the previous section.
  # CEP.machines, CEP.machineConfigs and CEP.machineImages must be set
  query_the_cep(ROOTS)

  # 3.2 Querying MachineTemplates
  # At least one MachineTemplate resource must appear in the collection
  it "should contain one MachineTemplates resource" do
    r = "machineTemplates".underscore.to_sym
    model = fetch(subject.send(r).href)
    log.info(model.attribute_values[r][0])
    assert_equal model.attribute_values[r][0].nil?(), false
  end

  it "should have a name" do
    machineTemplate.name.wont_be_empty
  end

  it "should have a response code equal to 200" do
    machineTemplate
    last_response.code.must_equal 200
  end

  it "should have a machineConfig" do
    machineTemplate.machine_config["href"].wont_be_empty
  end

  it "should have a machineImage" do
    machineTemplate.machine_image["href"].wont_be_empty
  end

  # 3.3 Creating a new machine
  model :machine do |fmt|
    cep_json = cep(:accept => :json)
    #discover the 'addURI' for creating Machine
    add_uri = discover_uri_for("add", "machines")
    post(add_uri,
      "<Machine>" +
        "<name>cimi_machine_from_template" + fmt.to_s() + "</name>" +
        "<description> Created machine from template" + fmt.to_s() + "</description>" +
        "<machineTemplate " +
          "href=\"" + get_a(cep_json, "machineTemplate")+ "\"/>" +
      "</Machine>",
         :accept => fmt, :content_type => :xml)
  end

  it "should add resource for cleanup" do
    @@created_resources[:machine_templates] << machineTemplate.id
  end

  it "should have a name" do
    machine.name.wont_be_empty
    log.info("machine name: " + machine.name)
  end

  it "should produce a valid create response" do
    machine
    last_response.code.must_be_one_of [201, 202]
    last_response.headers[:location].must_be_uri
  end

end
