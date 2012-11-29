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

class ManipulateAMachine < CIMI::Test::Spec
  RESOURCE_URI =
    "http://schemas.dmtf.org/cimi/1/Machine"

  MiniTest::Unit.after_tests {  teardown(@@created_resources, api.basic_auth) }

  # 2.1: Query the Machine
  # For some providers - need to create a machine before querying it.
  cep_json = cep(:accept => :json)
  machine_created = RestClient.post(cep_json.json["machines"]["href"],
    "<Machine>" +
      "<name>cimi_machine_part5</name>" +
      "<machineTemplate>" +
        "<machineConfig " +
          "href=\"" + cep_json.json["machineConfigs"]["href"] + "/" + api.provider_perferred_config + "\"/>" +
        "<machineImage " +
          "href=\"" + cep_json.json["machineImages"]["href"] + "/" + api.provider_perferred_image + "\"/>" +
      "</machineTemplate>" +
    "</Machine>",
    {'Authorization' => api.basic_auth, :accept => :json})

  model :machine do |fmt|
    get machine_created.json["id"], :accept => fmt
  end

  it "should add resource for cleanup", :only => :json do
    @@created_resources[:machines] << machine_created.json["id"]
  end

  it "should have a name" do
    log.info("machine name: " + machine.name)
    machine.name.wont_be_empty
  end

  it "should have have a description" do
    machine.description.wont_be_empty
  end

  it "should have an id including the cep url" do
   log.info("machine id: " + machine.id)
   machine.id.must_include api.cep_url.gsub("cloudEntryPoint", "machines/")
  end

  it "should have a valid creation time" do
    Time.parse(machine.created.to_s()) < Time.now
  end

  it "should have numerical values for memory and cpu" do
    machine.cpu.to_s.must_match /^[0-9]+$/
    machine.memory.to_s.must_match /^[0-9]+$/
  end

  it "should have a valid state" do
    s = Set.new ["RUNNING", "NEW", "PAUSED", "STOPPED", "STARTED"]
    log.info("machine state: " + machine.state.upcase)
    s.must_include machine.state.upcase
  end

  it "should have disks and columes collections" do
    machine.disks.must_respond_to :href, "disks collection"
    machine.volumes.must_respond_to :href, "volumes collection"
  end

  it "should have a response code equal to 200" do
    machine
    last_response.code.must_equal 200
  end

  it "should return correct content type" do
    machine
    last_response.wont_be_nil
    last_response.headers[:content_type].eql?(:fmt)
  end

  it "should return possible operations to be executed on a machine" do
    if (machine.state.upcase.eql?("RUNNING") ||
      machine.state.upcase.eql?("STARTED"))
      log.info(RESOURCE_URI.gsub("Machine", "action/restart"))
        # This relies on odering and needs to be improved
      machine[:operations][0][0].must_include RESOURCE_URI.gsub( "Machine", "action/restart")
      machine[:operations][1][0].must_include RESOURCE_URI.gsub( "Machine", "action/stop")
      machine[:operations][2][0].must_include RESOURCE_URI.gsub( "Machine", "action/capture")
    elsif machine.state.upcase.eql?("STOPPED")
      machine[:operations][0][0].must_include RESOURCE_URI.gsub( "Machine", "action/start")
      machine[:operations][1][0].must_include RESOURCE_URI.gsub( "Machine", "action/destroy")
      machine[:operations][2][0].must_include RESOURCE_URI.gsub( "Machine", "action/capture")
    else
      log.info("machine is in an intermediate state: " +  machine.state)
    end
  end

  # 52., 5.3: Start, stop the machine
  it "should be able to start and stop machines" do
    if (machine.state.upcase.eql?("RUNNING") ||
      machine.state.upcase.eql?("STARTED"))
       machine_stop_start(machine, "stop", "STOPPED")
        machine_stop_start(machine, "start", "STARTED")
    elsif machine.state.upcase.eql?("STOPPED")
      machine_stop_start(machine, "start", "STARTED")
      machine_stop_start(machine, "stop", "STOPPED")
    else
      log.info("machine is in an intermediate state: " +  machine.state)
    end
  end

  # 5.4: Modify a Machine attribute
  log.info("Modifying machine attributes is not supported - Deltacloud CIMI interface.")

end
