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

  need_capability("add", "volumes")

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
#no point creating machine if we can't run these tests:
   begin
     discover_uri_for("add", "volumes") # this will raise the RuntimeError
     machine = post(machine_add_uri,
       "<MachineCreate xmlns=\"#{CIMI::Test::CIMI_NAMESPACE}\">" +
         "<name>cimi_machine</name>" +
         "<machineTemplate>" +
           "<machineConfig " +
             "href=\"" + get_a(cep_json, "machineConfig") + "\"/>" +
           "<machineImage " +
             "href=\"" + get_a(cep_json, "machineImage") + "\"/>" +
          "</machineTemplate>" +
        "</MachineCreate>", {:accept => :json, :content_type => :xml})
    rescue RuntimeError =>e
    end


  #need to create a new VolumeConfiguration before creating the Volume:
  cep_json = cep(:accept => :json)
  volume_config_add_uri = discover_uri_for("add", "volumeConfigs")
  volume_config_resp = post(volume_config_add_uri,
     "<VolumeConfigurationCreate xmlns=\"#{CIMI::Test::CIMI_NAMESPACE}\">" +
       "<name>marios_volume_config</name>" +
       "<description>a volume configuration</description>"+
       "<format>ext3</format>"+
       " <capacity>1</capacity>" +
     "</VolumeConfigurationCreate>", {:accept => :json, :content_type => :xml})
  log.info("just created volume_configuration " + volume_config_resp.json["id"])

  # 4.3:  Create a new Volume
  model :volume, :cache => true do |fmt|
    volume_add_uri = discover_uri_for("add", "volumes")
    resp = post(volume_add_uri,
      "<VolumeCreate xmlns=\"#{CIMI::Test::CIMI_NAMESPACE}\">" +
        "<name>cimi_volume_" + fmt.to_s() +"</name>" +
        "<description>volume for testing</description>" +
        "<volumeTemplate>" +
          "<volumeConfig href=\"" + get_a(cep_json, "volumeConfig") + "\">" +
          "</volumeConfig>" +
        "</volumeTemplate>" +
      "</VolumeCreate>",
         :accept => fmt, :content_type => :xml)
    resp.code.must_be_one_of [201, 202]
    resp.location.must_be_uri
    get resp.location
  end

  it "should allow creation of Volume with Config by value in XML" do
    volume_add_uri = discover_uri_for("add", "volumes")
    res = post(volume_add_uri,
      "<VolumeCreate xmlns=\"#{CIMI::Test::CIMI_NAMESPACE}\">" +
        "<name>cimi_volume_by_value_xml</name>" +
        "<description>volume for testing</description>" +
        "<volumeTemplate>" +
          "<volumeConfig>" +
            "<type>http://schemas.dmtf.org/cimi/1/mapped</type>"+
            "<capacity> 1024 </capacity>" +
          "</volumeConfig>" +
        "</volumeTemplate>" +
      "</VolumeCreate>",
         :accept => :json, :content_type => :xml)
    res.code.must_be_one_of [201, 202]
    #cleanup
    delete_uri = discover_uri_for("delete", "volumes", res.json["operations"])
    res= delete(delete_uri)
    res.code.must_equal 200
  end

  it "should allow creation of Volume with Config by value in JSON" do
    volume_add_uri = discover_uri_for("add", "volumes")
    res = post(volume_add_uri,
      '{"name": "marios_new_volume_json", "description": "a new volume",' +
        ' "volumeTemplate":'+
            '{"volumeConfig": '+
              '{"type":"http://schemas.dmtf.org/cimi/1/mapped", "capacity": 1024 }}}',
       :accept => :json, :content_type => :json)
    res.code.must_be_one_of [201, 202]
    #cleanup
    delete_uri = discover_uri_for("delete", "volumes", res.json["operations"])
    res= delete(delete_uri)
    res.code.must_equal 200
  end


  #this test is not strictly part of the cimi plugfest scenario
  #added for DTACLOUD-385
  it "should add resource machine resource for cleanup", :only => :json do
    @@created_resources[:machines] << machine.location
  end

#  it "should add resource for cleanup" do
#    @@created_resources[:volumes] << volume.id
#  end
  it "should have a name" do
    volume.name.wont_be_empty
    log.info("volume name: " + volume.name)
  end

  it "should have the correct resourceURI", :only => :json do
    volume.wont_be_nil
    last_response.json["resourceURI"].must_equal RESOURCE_URI.gsub("Create", "")
  end

  if machine # machine not created if we can't create volumes here
    log.info("#{machine.location} is the machine id")
    volume_add_uri = discover_uri_for("add", "volumes")
    volume = post(volume_add_uri,
    "<VolumeCreate xmlns=\"#{CIMI::Test::CIMI_NAMESPACE}\">" +
      "<name>cimi_volume_for_attach</name>" +
      "<description>volume for attach testing</description>" +
      "<volumeTemplate>" +
        "<volumeConfig href=\"" + get_a(cep_json, "volumeConfig") + "\">" +
        "</volumeConfig>" +
      "</volumeTemplate>" +
    "</VolumeCreate>",
    :accept => :json, :content_type => :xml)
    log.info(volume.location + " is the volume id")
  end

  # 4.4: Attach the new Volume to a Machine
  model :machineWithVolume, :only => :xml do
    attach_uri = discover_uri_for_subcollection("add", machine.location, "volumes")
    resp = post(attach_uri,
    "<MachineVolume xmlns=\"#{CIMI::Test::CIMI_NAMESPACE}\">" +
    "<initialLocation>/dev/sdf</initialLocation>" +
    "<volume href=\"" + volume.location + "\"/>" +
    "</MachineVolume>",
    :accept => :xml, :content_type => :xml)
    resp.code.must_be_one_of [201, 202]
    resp.location.must_be_uri
    get resp.location
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
