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

class MachinesRMDDefaultInitialState < CIMI::Test::Spec
  RESOURCE_URI =
  "http://schemas.dmtf.org/cimi/1/Machine"
  ROOTS = ["machine", "resourceMetadata"]
  DEFAULT_INITIAL_STATE_CAPABILITY_URI = "http://schemas.dmtf.org/cimi/1/capability/Machine/DefaultInitialState"

  need_rmd(RESOURCE_URI, "capabilities", DEFAULT_INITIAL_STATE_CAPABILITY_URI)


  MiniTest::Unit.after_tests { teardown(@@created_resources, api.basic_auth) }

  #  Ensure test executes in test plan order
  i_suck_and_my_tests_are_order_dependent!

  # This test applies only if the ResourceMetadata corresponding to the
  # Machine resource contains a DefaultInitialState capability.

  # 3.1: Query the ResourceMetadata entry
  cep_json = cep(:accept => :json)
  rmd_coll = get cep_json.json[ROOTS[1]]["href"], :accept => :json
  machine_index = rmd_coll.json["resourceMetadata"].index {|rmd| rmd["typeUri"] ==  RESOURCE_URI}

  unless  machine_index.nil?() || rmd_coll.json["resourceMetadata"][machine_index]["capabilities"].nil?()
    default_initial_state_index = rmd_coll.json["resourceMetadata"][machine_index]["capabilities"].index {|rmd| rmd["uri"] == DEFAULT_INITIAL_STATE_CAPABILITY_URI}
    unless default_initial_state_index.nil?()
      default_initial_state_value = rmd_coll.json["resourceMetadata"][machine_index]["capabilities"][default_initial_state_index]["value"]

      model :resource_metadata_machine do |fmt|
        get rmd_coll.json["resourceMetadata"][machine_index]["id"], :accept => fmt
      end
    end
  end

  it "should have a response code equal to 200" do
    resource_metadata_machine
    last_response.code.must_equal 200
  end

  it "should return the DefaultInitialState capability", :only => :json do
    resource_metadata_machine
    unless last_response.json["capabilities"].nil?()
      log.info("Testing resource metadata: " + last_response.json["capabilities"].to_s())
      (last_response.json["capabilities"].any?{ |capability| capability["name"].include? "DefaultInitialState"}).must_equal true
      log.info(last_response.json["capabilities"])
    end
  end

  # 3.2: Inspect the capability
  it "should contain name, uri (unique), description, a single value", :only => :json do
    resource_metadata_machine

    elements = ["name", "uri", "description", "value"]
    (elements.all? { |element| last_response.json["capabilities"][default_initial_state_index].include? element}).must_equal true

    (last_response.json["capabilities"][default_initial_state_index]["value"].include? ',').must_equal false
  end

  # 3.3 Put collection member in state to verify capability
  # Create a new machine
  unless default_initial_state_index.nil?()
    cep_json = cep(:accept => :json)
    # discover the 'addURI' for creating Machine
    add_uri = discover_uri_for("add", "machines")
    resp = post(add_uri,
    "<MachineCreate>" +
    "<name>cimi_machine_" + rand(6).to_s + "</name>" +
    "<machineTemplate>" +
    "<machineConfig " +
    "href=\"" + get_a(cep_json, "machineConfig")+ "\"/>" +
    "<machineImage " +
    "href=\"" + get_a(cep_json, "machineImage") + "\"/>" +
    "</machineTemplate>" +
    "</MachineCreate>", :accept => :json, :content_type => :xml)

    model :machine do |fmt|
      get resp.json["id"], :accept => fmt
    end
  end

  it "should add resource for cleanup", :only => :json do
    @@created_resources[:machines] << resp.json["id"]
  end

  it "should have a name" do
    log.info("machine name: " + machine.name)
    machine.name.wont_be_empty
  end

  # 3.4:  Execute a query/action to expose the capability
  # Execute a GET /machines/new_machine_id operation to return the machine stable initial state
  it "should have a state equal to default initial state" do
    $i=0
    machine
    while (not machine.state.upcase.eql?(default_initial_state_value.upcase)) && ($i < 5)
      puts machine.state
      puts 'waiting for machine to be: ' + default_initial_state_value
      sleep(5)
      machine = machine(:refetch => true)
      $i +=1
    end

    machine = machine(:refetch => true)
    machine.state.upcase.must_equal default_initial_state_value
   end

  # 3.5: Cleanup
  # see @created_resources

end