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

class CloundEntryPointBehavior < CIMI::Test::Spec

  ROOTS = [ "resourceMetadata", "systems", "systemTemplates",
            "machines" , "machineTemplates", "machineConfigs",
            "machineImages", "credentials", "credentialTemplates",
            "volumes", "volumeTemplates", "volumeConfigs", "volumeImages",
            "networks", "networkTemplates", "networkConfigs", "networkPorts",
            "networkPortTemplates", "networkPortConfigs",
            "addresses", "addressTemplates", "forwardingGroups",
# FIXME: accessing this collection causes the thin process to take
#        all available memory
#            "forwardingGroupTemplates",
            "jobs", "meters", "meterTemplates", "meterConfigs",
            "eventLogs", "eventLogTemplates" ]

  RESOURCE_URI = "http://schemas.dmtf.org/cimi/1/CloudEntryPoint"

  #  Ensure test executes in test plan order
  i_suck_and_my_tests_are_order_dependent!

  # We'd like to call this :cep, but there's already a method by that name
  model :subject, :cache => true do |fmt|
    cep(:accept => fmt)
  end

  it "should have an id equal to the CEP URL" do
    subject.id.must_equal api.cep_url
  end

  it "should have a baseURI" do
    subject.base_uri.must_be_uri
  end

  it "should have a name" do
    subject.name.wont_be_empty
  end

  it "should have a response code equal to 200" do
    subject
    last_response.code.must_equal 200
  end

  it "should have the correct resourceURI", :only => :json do
    subject.wont_be_nil     # Make sure we talk to the server
    last_response.json["resourceURI"].must_equal RESOURCE_URI
  end

  query_the_cep(ROOTS)

  # Testing "*/*" Accept Headers returns json output
  response = RestClient.get(api.cep_url, "Accept" => "*/*")
  log.info( " */* accept headers return: " + response.json.to_s() )

  it "should return json response", :only => "*/*" do
    response.wont_be_nil
    response.headers[:content_type].eql?("application/json")
  end

  it "should have a response code equal to 200", :only => "*/*" do
    response.code.must_equal 200
  end

  it "should have an id equal to the CEP URL" , :only => "*/*" do
    response.json["id"].must_equal api.cep_url
  end

  it "should have a baseURI" do
    response.json["baseURI"].must_be_uri
  end

end
