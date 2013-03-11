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
require "set"
require "time"

class CaptureAMachine < CIMI::Test::Spec
  RESOURCE_URI =
    "http://schemas.dmtf.org/cimi/1/MachineImage"
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
      "<name>cimi_machine_machex1</name>" +
      "<description> created as part of tests/cimi/machex1_test  </description>" +
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

  # 3. Find the capture operation
  it "should advertise a capture operation", :only => :json do

  s = Set.new ["STOPPED", "STARTED"]
  machine = get(machine_created.json["id"], :accept=>:json)
        5.times do |j|
          break if s.include?(machine.json["state"].upcase)
          puts machine.json["state"]
          puts 'waiting for machine to be in a stable initial state'
          sleep(5)
          machine = get(machine_created.json["id"], :accept=>:json)
        end unless s.include?(machine.json["state"].upcase)

    if (discover_uri_for("capture","", machine.json["operations"]).nil?())
      # Change the machine state and check for the capture operation
      if machine.state.upcase.eql?("STOPPED")
        machine_stop_start(machine, "start", "STARTED")
      elsif machine.state.upcase.eql?("STARTED")
        machine_stop_start(machine, "stop", "STOPPED")
      end
    end
    unless discover_uri_for("capture","", machine.json["operations"]).nil?()
      # Create a machineImage from the machine
      machineimage_add_uri = discover_uri_for("add", "machineImages")
      machine_image_created = post(machineimage_add_uri,
      "<machineImageCreate>" +
      "<name>machine_image_machex1</name>" +
      "<description> created as part of tests/cimi/machex1_test  </description>" +
      "<type> IMAGE </type>" +
      "<imageLocation> " + machine_created.json["id"] +
      "</imageLocation> " +
      "</machineImageCreate>",
      :accept => :json, :content_type => :xml)

      @@created_resources[:machine_images] << machine_image_created.json["id"]

      machine_image_created.code.must_be_one_of [201, 202]
      machine_image_created.json["name"].must_equal "machine_image_machex1"
      machine_image_created.json["id"].wont_be_empty
      machine_image_created.json["type"].upcase.must_equal "IMAGE"
      machine_image_created.json["state"].wont_be_empty
      machine_image_created.json["resourceURI"].must_equal RESOURCE_URI
    end
  end

 end
