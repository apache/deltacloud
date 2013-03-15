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

class RestartAMachine < CIMI::Test::Spec
  RESOURCE_URI =
    "http://schemas.dmtf.org/cimi/1/Machine"
  ROOTS = ["machines", "machineImages", "machineConfigurations"]

  MiniTest::Unit.after_tests {  teardown(@@created_resources, api.basic_auth) }

  #  Ensure test executes in test plan order
  i_suck_and_my_tests_are_order_dependent!

  # 1: Query the CEP
  model :subject, :cache => true do |fmt|
    cep(:accept => fmt)
  end

  # CEP.machines, CEP.machineConfigs and CEP.machineImages must be set
  query_the_cep(ROOTS)

  # 2: Create a new machine
  cep_json = cep(:accept => :json)
  # Discover machine create URI:
  machine_add_uri = discover_uri_for("add", "machines")
  machine_created = post(machine_add_uri,
    "<MachineCreate>" +
      "<name>cimi_machine_machex2</name>" +
      "<description> created as part of tests/cimi/machex2_test </description>" +
      "<machineTemplate>" +
        "<machineConfig " +
          "href=\"" + get_a(cep_json, "machineConfig") + "\"/>" +
        "<machineImage " +
          "href=\"" + get_a(cep_json, "machineImage") + "\"/>" +
      "</machineTemplate>" +
    "</MachineCreate>",
    :accept => :json, :content_type => :xml)

  model :machine do |fmt|
    get machine_created.json["id"], :accept => fmt
  end

  it "should add resource for cleanup", :only => :json do
    @@created_resources[:machines] << machine_created.json["id"]
  end

  # 3. Find the restart operation
  it "should advertise a restart operation" do

  s = Set.new ["STOPPED", "STARTED"]
  machine = get(machine_created.json["id"], :accept=>:json)
        5.times do |j|
          break if s.include?(machine.json["state"].upcase)
          puts machine.json["state"]
          puts 'waiting for machine to be in a stable initial state'
          sleep(5)
          machine = get(machine_created.json["id"], :accept=>:json)
        end unless s.include?(machine.json["state"].upcase)

    if (discover_uri_for("restart","", machine.json["operations"]).nil?())
      # Change the machine state and check for the restart operation
      machine = machine(:refetch => true)
      if machine.state.upcase.eql?("STOPPED")
        machine_stop_start(machine(:refetch => true), "start", "STARTED")
      elsif machine.state.upcase.eql?("STARTED")
        machine_stop_start(machine(:refetch => true), "stop", "STOPPED")
      end
    end
    unless discover_uri_for("restart","", machine.json["operations"]).nil?()
      # Restart the machine
      machine_stop_start(machine(:refetch => true), "restart", "STARTED")
      machine = get(machine_created.json["id"], :accept=>:json)
      machine.code.must_be_one_of [200, 202]
      machine.json["state"].must_equal "STARTED"
    end
  end

 end
