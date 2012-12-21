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

class MachineBehavior < CIMI::Test::Spec

  RESOURCE_URI = "http://schemas.dmtf.org/cimi/1/Machine"

  model :machine do |fmt|
    mcoll_uri = cep(:accept => :json).json["machines"]["href"]
    mcoll = get(mcoll_uri, :accept => :json).json
    m_url = mcoll["machines"][0]["id"]
    get m_url, :accept => fmt
  end

  it "should have the correct resourceURI", :only => :json do
    machine.wont_be_nil      # Make sure we talk to the server
    last_response.json["resourceURI"].must_equal RESOURCE_URI
  end

  it "should be able to create new machineImage from Machine" do
    #should have a running machine:
    cep_json = cep(:accept => :json)
    machine_id = get_a(cep_json, "machine")
    machine = get(machine_id, :accept=>:json)
    machine.wont_be_nil
    #discover 'create image' URI
    capture_uri = discover_uri_for("capture", "machines", machine.json["operations"])
    #now create the image:
    resp = post(capture_uri,
        "<MachineImage>"+
          "<name>image_from_#{machine_id.split("/").last}</name>"+
          "<description>my new machine image for machine_test.rb</description>"+
          "<type>IMAGE</type>"+
          "<imageLocation>#{machine_id}</imageLocation>"+
        "</MachineImage>", {:accept=> :json, :content_type => :xml})
    #checks:
    resp.code.must_equal 201
    resp.headers[:location].must_be_uri
    resp.json["id"].must_equal resp.headers[:location]
    #retrieve new image:
    image_id = resp.json["id"]
    resp = get(image_id, :accept=>:json)
    resp.code.must_equal 200
    resp.json["resourceURI"].must_include "MachineImage"
    resp.json["id"].must_equal image_id
    #cleanup:
    resp = delete(image_id)
    resp.code.must_equal 200
  end

end
