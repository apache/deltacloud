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
describe "MachineConfiguration model" do

  before(:all) do
    @xml = IO::read(File::join(DATA_DIR, "machine_configuration.xml"))
    @json = IO::read(File::join(DATA_DIR, "machine_configuration.json"))
  end

  it "can be constructed from XML" do
    conf = CIMI::Model::MachineConfiguration.from_xml(@xml)
    conf.should_not be_nil
    conf.name.should == 'MachineConfiguration1'
    conf.uri == 'http://cimi.example.org/machine_configurations/1'
    conf.description == 'Example MachineConfiguration One'
    conf.created.should == "2011-11-14"
    conf.cpu.should == "2"
    conf.memory.size.should == 1
    conf.memory[0]['quantity'].should == '1'
    conf.memory[0]['units'].should == 'gigabyte'
    conf.disk.size.should == 1
    conf.disk[0].respond_to?(:capacity).should be_true
    conf.disk[0].capacity.size.should == 1
    conf.disk[0].capacity[0]['format'] == 'ext4'
    conf.disk[0].capacity[0]['quantity'] == '1'
    conf.disk[0].capacity[0]['attachmentPoint'] == '/'
    conf.disk[0].capacity[0]['units'] == 'terabyte'
    conf.operations.size.should == 2
    conf.operations.any? { |operation| operation.rel == 'edit' }.should be_true
    conf.operations.any? { |operation| operation.rel == 'delete' }.should be_true
    conf.operations.each { |operation| operation.href.should =~ /^http:\/\/.*\/(#{operation.rel})$/ }
    conf.should serialize_to @xml, :fmt => :xml
  end

  it "should convert strings in keys to symbols when contructed from XML" do
    conf = CIMI::Model::MachineConfiguration.from_xml(@xml)
    conf.should_not be_nil
    conf.attribute_values.keys.each { |key| key.should be_a(Symbol) }
  end

  it "can be constructed from JSON" do
    conf = CIMI::Model::MachineConfiguration.from_json(@json)
    conf.should_not be_nil
    conf.name.should == 'MachineConfiguration1'
    conf.uri == 'http://cimi.example.org/machine_configurations/1'
    conf.description == 'Example MachineConfiguration One'
    conf.created.should == "2011-11-14"
    conf.cpu.should == "2"
    conf.memory.size.should == 1
    conf.memory[0]['quantity'].should == '1'
    conf.memory[0]['units'].should == 'gigabyte'
    conf.disk.size.should == 1
    conf.disk[0].respond_to?(:capacity).should be_true
    conf.disk[0].capacity.size.should == 1
    conf.disk[0].capacity[0]['format'] == 'ext4'
    conf.disk[0].capacity[0]['quantity'] == '1'
    conf.disk[0].capacity[0]['attachmentPoint'] == '/'
    conf.disk[0].capacity[0]['units'] == 'terabyte'
    conf.operations.size.should == 2
    conf.operations.any? { |operation| operation.rel == 'edit' }.should be_true
    conf.operations.any? { |operation| operation.rel == 'delete' }.should be_true
    conf.operations.each { |operation| operation.href.should =~ /^http:\/\/.*\/(#{operation.rel})$/ }
    conf.should serialize_to @json, :fmt => :json
  end
end
