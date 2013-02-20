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

class MachinesRMDInitialStates < CIMI::Test::Spec
  @@created_resources ||= {}
  @@created_resources[:machines] ||= []
  RESOURCE_URI =
  "http://schemas.dmtf.org/cimi/1/Machine"
  ROOTS = ["machine", "resourceMetadata"]
  INITIAL_STATES_CAPABILITY_URI = "http://schemas.dmtf.org/cimi/1/capability/Machine/InitialStates"
  DEFAULT_INITIAL_STATE_CAPABILITY_URI = "http://schemas.dmtf.org/cimi/1/capability/Machine/DefaultInitialState"

  need_rmd(RESOURCE_URI, "capabilities", INITIAL_STATES_CAPABILITY_URI)

  MiniTest::Unit.after_tests { teardown(@@created_resources, api.basic_auth) }

  #  Ensure test executes in test plan order
  i_suck_and_my_tests_are_order_dependent!

  # This test applies only if the ResourceMetadata corresponding to the
  # Machine resource contains the InitialStates capability.
  # 4.1: Query the ResourceMetadata entry
  cep_json = cep(:accept => :json)
  rmd_coll = get cep_json.json[ROOTS[1]]["href"], :accept => :json
  machine_index = rmd_coll.json["resourceMetadata"].index {|rmd| rmd["typeUri"] ==  RESOURCE_URI}
  unless  machine_index.nil?() || rmd_coll.json["resourceMetadata"][machine_index]["capabilities"].nil?()
    initial_states_index = rmd_coll.json["resourceMetadata"][machine_index]["capabilities"].index {|rmd| rmd["uri"] == INITIAL_STATES_CAPABILITY_URI}
    unless initial_states_index.nil?()
      initial_states_value = rmd_coll.json["resourceMetadata"][machine_index]["capabilities"][initial_states_index]["value"]

      model :resource_metadata_machine do |fmt|
        get rmd_coll.json["resourceMetadata"][machine_index]["id"], :accept => fmt
      end
    end
  end

  it "should have a response code equal to 200" do
    resource_metadata_machine
    last_response.code.must_equal 200
  end

  it "should return the InitialStates capability", :only => :json do
    resource_metadata_machine
    unless last_response.json["capabilities"].nil?()
      log.info("Testing resource metadata: " + last_response.json["capabilities"].to_s())
      (last_response.json["capabilities"].any?{ |capability| capability["name"].include? "InitialStates"}).must_equal true
      log.info(last_response.json["capabilities"])
    end
  end

  # 4.2: Inspect the capability
  it "should contain name, uri (unique), description, value(s)", :only => :json do
    resource_metadata_machine

    elements = ["name", "uri", "description", "value"]
    (elements.all? { |element| last_response.json["capabilities"][initial_states_index].include? element}).must_equal true

  end

  # 4.3 Put collection member in state to verify capability

  # Create a new machine
  cep_json = cep(:accept => :json)

  # Discover the 'addURI' for creating Machine
  add_uri = discover_uri_for("add", "machines")
  # Specify a desired initial state which is different from
  # the default value (see DefaultInitalState capability)

  unless rmd_coll.json["resourceMetadata"][machine_index]["capabilities"].nil?()
    default_initial_state_value = rmd_coll.json["resourceMetadata"][machine_index]["capabilities"].inject([]){|res, cur| res = cur["value"] if cur["uri"] == DEFAULT_INITIAL_STATE_CAPABILITY_URI; res}
  end

  unless initial_states_value.nil?() || default_initial_state_value.nil?()
    @@rmd4_created_machines = {}
    (0..(initial_states_value.split(",").size() - 1)).each do |i|
      chosen_initial_state = initial_states_value.split(',')[i]

      if !chosen_initial_state.eql? default_initial_state_value
        puts "Testing initial state value: " + chosen_initial_state
      else
        puts "Testing initial state value - " +
        " equal to the default initial state: " + chosen_initial_state
      end

      resp = post(add_uri,
      "<Machine>" +
      "<name>cimi_machine_" + i.to_s + "</name>" +
      "<machineTemplate>" +
      "<initialState>" + chosen_initial_state + "</initialState>" +
      "<machineConfig " +
      "href=\"" + get_a(cep_json, "machineConfig")+ "\"/>" +
      "<machineImage " +
      "href=\"" + get_a(cep_json, "machineImage") + "\"/>" +
      "</machineTemplate>" +
      "</Machine>", :accept => :json, :content_type => :xml)

      @@rmd4_created_machines.merge!(chosen_initial_state => resp.json["id"])

      model :machine do |fmt|
        get resp.json["id"], :accept => fmt
      end

      it "should add resource for cleanup", :only => :json do
        @@created_resources[:machines] << resp.json["id"]
      end

      it "should have a 201 (or 202) created response code" do
        resp.code.must_be_one_of [201, 202]
      end

      it "should have a name" do
        log.info("machine name: " + machine.name)
        machine.name.wont_be_empty
      end

      # 4.4:  Execute a query/action to expose the capability
      # Execute a GET /machines/new_machine_id operation to return the machine
      # stable initial state
      it "should have a state equal to the specified initial state" do
        machine = get(@@rmd4_created_machines[chosen_initial_state], :accept=>:json)
        5.times do |j|
          break if machine.json["state"].upcase.eql?(chosen_initial_state.upcase)
          puts machine.json["state"]
          puts 'waiting for machine to be: ' + chosen_initial_state
          sleep(5)
          machine = get(@@rmd4_created_machines[chosen_initial_state], :accept=>:json)
        end unless machine.json["state"].upcase.eql?(chosen_initial_state.upcase)

        machine.json["state"].upcase.must_equal chosen_initial_state
      end

      # 4.5: Cleanup
      # see @created_resources

      # 4.6: Repeat the test for initial states advertised
      # (if there are more states to test)
    end
  end
end
