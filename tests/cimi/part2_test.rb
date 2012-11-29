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

  # 2.5: Create a new Machine
  model :machine do |fmt|
    cep_json = cep(:accept => :json)

    RestClient.post(cep_json.json["machines"]["href"],
      "<Machine>" +
        "<name>cimi_machine_" + fmt.to_s() + "</name>" +
        "<machineTemplate>" +
          "<machineConfig " +
            "href=\"" + cep_json.json["machineConfigs"]["href"] + "/" + api.provider_perferred_config + "\"/>" +
          "<machineImage " +
            "href=\"" + cep_json.json["machineImages"]["href"] + "/" + api.provider_perferred_image + "\"/>" +
        "</machineTemplate>" +
      "</Machine>",
      {'Authorization' => api.basic_auth, :accept => fmt})
  end

  it "should add resource for cleanup" do
    @@created_resources[:machines] << machine.id
  end

  it "should have a name" do
    machine.name.wont_be_empty
    log.info("machine name: " + machine.name)
  end

  it "should have a response code equal to 201" do
    machine
    last_response.code.must_equal 201
  end

end
