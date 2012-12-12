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

class CreateNewMachineFromMachineTemplate < CIMI::Test::Spec
  RESOURCE_URI =
    "http://schemas.dmtf.org/cimi/1/CloudEntryPoint"

  MiniTest::Unit.after_tests { teardown(@@created_resources, api.basic_auth) }

  #  Ensure test executes in test plan order
  i_suck_and_my_tests_are_order_dependent!

  model :subject, :cache => true do |fmt|
    cep(:accept => fmt)
  end

  #create a machineTemplate for use in these tests:
  cep_json = cep(:accept => :json)
  mach_templ_add_uri = discover_uri_for("add", "machineTemplates")
  templ = CIMI::Model::MachineTemplate.new(
    :name => "cimi_machineTemplate1",
    :description => "A CIMI MachineTemplate, created by part3_test.rb",
    :property => { "foo" => "bar" },
    :machine_config => { :href => get_a(cep_json, "machineConfig") },
    :machine_image => { :href => get_a(cep_json, "machineImage") } )

  mach_templ_created = post(mach_templ_add_uri, templ.to_xml,
                            :accept => :json, :content_type => :xml)

  # 3.1: Query the CEP
  model :machineTemplate  do |fmt|
    get mach_templ_created.headers[:location], :accept => fmt
  end

  # 3.2 Querying MachineTemplates
  # At least one MachineTemplate resource must appear in the collection
  it "should contain one MachineTemplates resource" do
    model = fetch(subject.machine_templates.href)
    assert_operator 0, :<, model.count.to_i
    model.machine_templates[0].wont_be_nil
  end

  it "should have a name" do
    machineTemplate.name.wont_be_empty
  end

  it "should have a response code equal to 200" do
    machineTemplate
    last_response.code.must_equal 200
  end

  it "should have a machineConfig" do
    machineTemplate.machine_config["href"].wont_be_empty
  end

  it "should have a machineImage" do
    machineTemplate.machine_image["href"].wont_be_empty
  end

  it "allows creation of a machine from a template (step 3.3)",
     :only => :json do
    cep_json = cep(:accept => :json)
    add_uri = discover_uri_for("add", "machines")
    resp = post(add_uri,
      "<MachineCreate xmlns=\"#{CIMI::Test::CIMI_NAMESPACE}\">" +
         "<name>cimi_machine_from_template_#{format}</name>" +
         "<description> Created machine from template #{format}</description>" +
        "<machineTemplate " +
          "href=\"" + get_a(cep_json, "machineTemplate")+ "\"/>" +
      "</MachineCreate>",
         :accept => format, :content_type => :xml)

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
