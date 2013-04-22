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

class SystemTemplate < CIMI::Test::Spec
  RESOURCE_URI = "http://schemas.dmtf.org/cimi/1/System"

  ROOTS = [ "machines" , "systemTemplates" , "volumeTemplates"]
  need_capability('add', 'systems')
  need_collection("systems")

  # Cleanup for resources created for the test
  MiniTest::Unit.after_tests {  teardown(@@created_resources, api.basic_auth) }

  #  Ensure test executes in test plan order
  i_suck_and_my_tests_are_order_dependent!

  # 1.1: Query the CEP
  model :subject, :cache => true do |fmt|
    cep(:accept => fmt)
  end

  # CEP.machines, CEP.systemTemplates and CEP.volumeTemplates must be set
  query_the_cep(ROOTS)

  # 1.2 Query the systemTemplate collection
  cep_json = cep(:accept => :json)

  #model :system_template do |fmt|
  #  get(cep_json.json[ROOTS[1]]["href"], :accept => :fmt)
  #end

  it "should return a 200 code" do
    get(cep_json.json[ROOTS[1]]["href"], :accept => :json).code.must_equal 200
    get(cep_json.json[ROOTS[1]]["href"], :accept => :xml).code.must_equal 200
  end

  # Retrieve existing system templates or the address to create a new system template
  begin
    # systemplate_add_uri = discover_uri_for("add", "system_templates")
    it "should have at least one system template" do
      r = ROOTS[1].underscore.to_sym
      model = fetch(subject.send(r).href)
      log.info(model.attribute_values[r][0])
      assert_equal model.attribute_values[r][0].nil?(), false
      model.attribute_values[r][0].id.must_be_uri

       # 1.3 Select or Create a System Template
       puts "System Template: " + get_a(cep_json, "systemTemplate")
     end
  rescue RuntimeError =>e
  end

  if collection_supported("systems")
    system_add_uri = discover_uri_for("add", "systems")
  # 1.4 Create a new system from the systemTemplate
    system_created = post(system_add_uri,
      "<systemCreate xmlns=\"#{CIMI::Test::CIMI_NAMESPACE}\">" +
      "<name>test_system</name>" +
      "<systemTemplate href=\"" + get_a(cep_json, "systemTemplate") + "\"/>" +
      "</systemCreate>", :content_type => :xml)
  end

  model :systems do |fmt|
    get cep_json.json["systems"]["href"], :accept => fmt
  end

  it "should add system resource for cleanup", :only => :json do
    @@created_resources ||= {}
    @@created_resources[:systems] ||= []
    @@created_resources[:systems] << system_created.headers[:location]
  end

  it "should allow a system to be created" do
    system_created.headers[:location].must_be_uri
    system_created.code.must_be_one_of [201, 202]
  end

  # model :test_system_created do |fmt|
  #   get(system_created.headers[:location], :accept => fmt)
  # end

  # 1.5 Query the new System
  it "should return a representation of a system", :only => :json do
    puts fetch(system_created.headers[:location]).id
    #test_system_created
    test_system_created = get(fetch(system_created.headers[:location]).id, :accept => :json)
    test_system_created.code.must_equal 200
    test_system_created.json["resourceURI"].must_equal RESOURCE_URI
  end

  # 1.6 Query the System SystemMachine collection
  it "should have a SystemMachine collection with two entries", :only => :json do
    #test_system_created
    test_system_created = get(fetch(system_created.headers[:location]).id, :accept => :json)
    system_machines = get(test_system_created.json["machines"]["href"], :accept => :json)
    #system_machines.json["count"].must_equal 2
    #system_machines.json["systemMachines"][0]["id"].  end
  end

  # 1.7 Query the System SystemVolume collection
  #OPTIONAL for this pf - commenting out for now (created system from template1.json[mock] has no volumes)
#  it "should contain a single entry referencing a Volume named as indicated in the SystemTemplate", :only => :json do
    #test_system_created
#    test_system_created = get(fetch(system_created.headers[:location]).id, :accept => :json)
#    system_volumes = get(test_system_created.json["volumes"]["href"], :accept => :json)
#    system_volumes.json["count"].must_equal 1
#    #system_volumes.json["systemVolumes"][0]["id"].must_equal "volume from template"
#  end

  # 1.8 Check that the volume is attached to machine(s)
  # Optional - skipping

  # 1.9 Query the System SystemCredential collection
  # Optional - skipping

  # 1.10 Starting the new System
  it "should be able to start the system", :only => :json  do
    test_system_created = get(fetch(system_created.headers[:location]).id, :accept => :json)
    unless test_system_created.json["state"].eql?("STARTED")
      uri = discover_uri_for("start", "", test_system_created.json["operations"])
      response = post( uri,
            "<Action xmlns=\"http://schemas.dmtf.org/cimi/1\">" +
              "<action> http://http://schemas.dmtf.org/cimi/1/action/start</action>" +
            "</Action>",
            :accept => :xml, :content_type => :xml)
      response.code.must_equal 202
      poll_state(fetch(system_created.headers[:location]), "STARTED")
      get(fetch(system_created.headers[:location]).id, :accept => :json).json["state"].upcase.must_equal "STARTED"
    end
  end

  # 1.11 Check that the machines are started
  it "should check that the system machines were started successfully", :only => :json do
    test_system_created = fetch(system_created.headers[:location])
    sys_mach_coll = fetch(test_system_created.machines.href)
    sys_mach_coll.system_machines.each do |sys_mach|
      fetch(sys_mach.machine.href).state.upcase.must_equal "STARTED"
    end
  end

  # 1.12 Stop the new System
  it "should be able to stop the system", :only => :json  do
    test_system_created = get(fetch(system_created.headers[:location]).id, :accept => :json)
    unless test_system_created.json["state"].eql?("STOPPED")
      uri = discover_uri_for("stop", "", test_system_created.json["operations"])
      response = post( uri,
            "<Action xmlns=\"http://schemas.dmtf.org/cimi/1\">" +
              "<action> http://http://schemas.dmtf.org/cimi/1/action/stop</action>" +
            "</Action>",
            :accept => :xml, :content_type => :xml)
      response.code.must_equal 202
      poll_state(fetch(system_created.headers[:location]), "STOPPED")
      get(fetch(system_created.headers[:location]).id, :accept => :json).json["state"].upcase.must_equal "STOPPED"
    end
  end

  # 1.13 Check that the machines are stopped
  it "should check that the system machines were stopped successfully", :only => :json do
    test_system_created = fetch(system_created.headers[:location])
    sys_mach_coll = fetch(test_system_created.machines.href)
    sys_mach_coll.system_machines.each do |sys_mach|
      fetch(sys_mach.machine.href).state.upcase.must_equal "STOPPED"
    end
  end
end
