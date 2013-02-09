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

describe "MachineCreate model" do

  before do
    @xml = read_data_file("machine_create_by_value.xml")
  end

  it "can be constructed from XML with template by value" do
    mc = CIMI::Model::MachineCreate.from_xml(@xml)
    mc.name.must_equal "xml_machine_by_value"
    mt = mc.machine_template
    mt.wont_be_nil
    mt.href.must_be_nil
    mt.machine_config.href.wont_be_nil
  end

  it "can be built in code" do
    mc = CIMI::Model::MachineCreate.new(:name => "from_code")
    mc.machine_template.href = "/mts/1"
    mc.machine_template.machine_config.cpu = 42
    json = JSON::parse(mc.to_json)
    json["machineTemplate"]["href"].must_equal "/mts/1"
    json["machineTemplate"]["machineConfig"]["cpu"].must_equal 42
  end
end
