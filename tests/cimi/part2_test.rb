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

class CreateNewMachine < CIMI::Test::Spec
  RESOURCE_URI =
    "http://schemas.dmtf.org/cimi/1/CloudEntryPoint"
  ROOTS = ["machines", "machineImages", "machineConfigurations"]

  MiniTest::Unit.after_tests { teardown(@@created_resources, api.basic_auth) }

  #  Ensure test executes in test plan order
  i_suck_and_my_tests_are_order_dependent!

  # 2.1: Query the CEP
  model :subject, :cache => true do |fmt|
    cep(:accept => fmt)
  end

  # This test must adhere to one of the "Query the CEP" test in the previous section.
  query_the_cep(ROOTS)

  # At least one MachineImage resource must appear in the collection
  # At least one MachineConfiguration resource must appear in the collection
  it "should contain one MachineImage resource and one MachineConfiguration resource" do
  ROOTS.each do |root|
    r = root.underscore.to_sym
    unless r.eql?(:machines)
      model = fetch(subject.send(r).href)
      log.info(model.attribute_values[r][0])
      assert_equal model.attribute_values[r][0].nil?(), false
    end
  end
end

  # 2.4:  Create a new CredentialResource
  log.info("Create a new CredentialResource: credential_resources is not a supported collection.")

  it "allows creation of a new machine (step 2.5)", :only => :json do
    cep_json = cep(:accept => :json)
    #discover the 'addURI' for creating Machine
    add_uri = discover_uri_for("add", "machines")

    resp = post(add_uri,
      "<MachineCreate xmlns=\"#{CIMI::Test::CIMI_NAMESPACE}\">" +
        "<name>cimi_machine_" + format.to_s + "</name>" +
        "<machineTemplate>" +
          "<machineConfig " +
            "href=\"" + get_a(cep_json, "machineConfig")+ "\"/>" +
          "<machineImage " +
            "href=\"" + get_a(cep_json, "machineImage") + "\"/>" +
        "</machineTemplate>" +
      "</MachineCreate>", :content_type => :xml)

    resp.headers[:location].must_be_uri
    resp.code.must_be_one_of [201, 202]
    if resp.code == 201
      machine = fetch(resp.headers[:location])
      machine.name.wont_be_empty
    else
      machine = CIMI::Model::Machinemachine.new(:id => resp.headers[:location])
    end
    @@created_resources[:machines] << machine[:id]
  end
end
