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
#
require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative '../spec_helper.rb' if require 'minitest/autorun'

describe "MachineTemplate model" do

  before do
    @xml = read_data_file("machine_template.xml")
    @json = read_data_file("machine_template.json")
  end

  it "can be constructed from XML and JSON" do
    should_properly_serialize_model CIMI::Model::MachineTemplate, @xml, @json
  end

  describe "can have an embedded machineConfig" do
    MACHINE_CONFIG_ID = "http://cimi.example.org/machine_configs/1"

    it "in XML" do
      mt = CIMI::Model::MachineTemplate.from_xml(@xml)
      mt.name.must_equal "My First Template"
      mt.machine_config.href.must_equal MACHINE_CONFIG_ID
      mt.machine_config.id.must_be_nil
      mt.machine_config.cpu = 7

      mc = parse_xml(mt.to_xml)["MachineTemplate"].first["machineConfig"].first
      mc.wont_be_nil
      mc["href"].must_equal MACHINE_CONFIG_ID
      mc["cpu"].first["content"].must_equal "7"
    end

    it "in JSON" do
      mt = CIMI::Model::MachineTemplate.from_json(@json)
      mt.name.must_equal "My First Template"
      mt.machine_config.href.must_equal MACHINE_CONFIG_ID
      mt.machine_config.id.must_be_nil
      mt.machine_config.cpu = 7

      mc = JSON::parse(mt.to_json)["machineConfig"]
      mc.wont_be_nil
      mc["href"].must_equal MACHINE_CONFIG_ID
      mc["cpu"].must_equal 7
    end
  end
end
