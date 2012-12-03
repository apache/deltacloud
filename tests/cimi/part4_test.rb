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

class AddVolumeToMachine < CIMI::Test::Spec
  RESOURCE_URI = "http://schemas.dmtf.org/cimi/1/VolumeCreate"

  ROOTS = [ "machines" , "volumes" , "volumeConfigurations"]

  # Cleanup for resources created for the test
  MiniTest::Unit.after_tests {  teardown(@@created_resources, api.basic_auth) }

  #  Ensure test executes in test plan order
  i_suck_and_my_tests_are_order_dependent!

  # 4.1: Query the CEP
  model :subject, :cache => true do |fmt|
    cep(:accept => fmt)
  end

  # 4.2, 4.3: CEP.machines, CEP.volumes and CEP.volumeConfigs must be set
  query_the_cep(ROOTS)

  # At least one VolumeConfiguration resource must appear in the collection
  it "should have at least one volumeConfiguration collection" do
    ROOTS.each do |root|
      r = root.underscore.to_sym
      if r.eql?(:volume_configurations)
        model = fetch(subject.send(r).href)
        log.info(model.attribute_values[r][0])
        assert_equal model.attribute_values[r][0].nil?(), false
        model.attribute_values[r][0].id.must_be_uri
      end
    end
  end

# Create a machine to attach the volume
   cep_json = cep(:accept => :json)
   machine_add_uri = discover_uri_for("add", "machines")
   machine = RestClient.post(machine_add_uri,
     "<Machine>" +
       "<name>cimi_machine</name>" +
       "<machineTemplate>" +
         "<machineConfig " +
           "href=\"" + get_a(cep_json, "machineConfig") + "\"/>" +
         "<machineImage " +
           "href=\"" + get_a(cep_json, "machineImage") + "\"/>" +
       "</machineTemplate>" +
     "</Machine>",
     {'Authorization' => api.basic_auth, :accept => :json})

  # 4.3:  Create a new Volume
  model :volume do |fmt|
    volume_add_uri = discover_uri_for("add", "volumes")
    RestClient.post(volume_add_uri,
      "<Volume>" +
        "<name>cimi_volume_" + fmt.to_s() +"</name>" +
        "<description>volume for testing</description>" +
        "<volumeTemplate>" +
          "<volumeConfig href=\"" + get_a(cep_json, "volumeConfig") + "\">" +
          "</volumeConfig>" +
        "</volumeTemplate>" +
      "</Volume>",
    {'Authorization' => api.basic_auth, :accept => fmt})
  end

  it "should add resource machine resource for cleanup", :only => :json do
    @@created_resources[:machines] << machine.json["id"]
  end

#  it "should add resource for cleanup" do
#    @@created_resources[:volumes] << volume.id
#  end

  it "should have a name" do
    volume.name.wont_be_empty
    log.info("volume name: " + volume.name)
  end

  it "should have a response code equal to 201 for creating a volume" do
    volume
    last_response.code.must_equal 201
  end

  it "should have the correct resourceURI", :only => :json do
    volume.wont_be_nil
    last_response.json["resourceURI"].must_equal RESOURCE_URI.gsub("Create", "")
  end

  log.info(machine.json["id"].to_s() + " is the machine id")
  volume_add_uri = discover_uri_for("add", "volumes")
  volume = RestClient.post(volume_add_uri,
  "<Volume>" +
    "<name>cimi_volume_for_attach</name>" +
    "<description>volume for attach testing</description>" +
    "<volumeTemplate>" +
      "<volumeConfig href=\"" + get_a(cep_json, "volumeConfig") + "\">" +
      "</volumeConfig>" +
    "</volumeTemplate>" +
  "</Volume>",
{'Authorization' => api.basic_auth, :accept => :json})

  log.info(volume.json["id"].to_s() + " is the volume id")
  # 4.4: Attach the new Volume to a Machine
  model :machineWithVolume, :only => :xml do
  attach_uri = discover_uri_for_subcollection("add", machine.json['id'], "volumes")
    RestClient.post(attach_uri,
    "<MachineVolume xmlns=\"http://schemas.dmtf.org/cimi/1/MachineVolume\">" +
    "<initialLocation>/dev/sdf</initialLocation>" +
    "<volume href=\"" + volume.json["id"] + "\"/>" +
    "</MachineVolume>",
    {'Authorization' => api.basic_auth, :accept => :xml})
  end

  it "should have a response code equal to 201 for attaching a volume", :only => :xml do
    machineWithVolume
    last_response.code.must_equal 201
  end

  it "should have a delete operation", :only => :xml do
    machineWithVolume[:operations][0][0].must_include "delete"
  end

  it "should be able to detach from the instance", :only => :xml do
    detach_uri = discover_uri_for("delete", "", machineWithVolume.operations)
    response = RestClient.delete(detach_uri,
    {'Authorization' => api.basic_auth, :accept => :xml})
      response.code.must_equal 200
  end

end
