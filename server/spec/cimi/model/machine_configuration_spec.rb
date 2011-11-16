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

  describe 'XML' do
    it "can be constructed" do
      conf = CIMI::Model::MachineConfiguration.from_xml(@xml)
      conf.should_not be_nil
      conf.should serialize_to @xml, :fmt => :xml
    end

    it "should convert strings in keys to symbols when contructed from XML" do
      conf = CIMI::Model::MachineConfiguration.from_xml(@xml)
      conf.should_not be_nil
      conf.attribute_values.keys.each { |key| key.should be_a(Symbol) }
    end

    it "should have default properties" do
      conf = CIMI::Model::MachineConfiguration.from_xml(@xml)
      conf.name.should == 'MachineConfiguration1'
      conf.uri == 'http://cimi.example.org/machine_configurations/1'
      conf.description == 'Example MachineConfiguration One'
      conf.created.should == "2011-11-14"
    end

    it "should have cpu and memory properties" do
      conf = CIMI::Model::MachineConfiguration.from_xml(@xml)
      conf.cpu.should == "2"
      conf.memory.should be_an_instance_of Hash
      conf.memory['quantity'].should == '1'
      conf.memory['units'].should == 'gigabyte'
    end

    it "should have disk array property with capacity" do
      conf = CIMI::Model::MachineConfiguration.from_xml(@xml)
      conf.disk.size.should == 1
      conf.disk[0].respond_to?(:capacity).should be_true
      conf.disk[0].capacity.size.should == 1
      conf.disk[0].capacity[0]['format'] == 'ext4'
      conf.disk[0].capacity[0]['quantity'] == '1'
      conf.disk[0].capacity[0]['attachmentPoint'] == '/'
      conf.disk[0].capacity[0]['units'] == 'terabyte'
    end

    it "should have edit and delete operations" do
      conf = CIMI::Model::MachineConfiguration.from_xml(@xml)
      conf.operations.size.should == 2
      conf.operations.any? { |operation| operation.rel == 'edit' }.should be_true
      conf.operations.any? { |operation| operation.rel == 'delete' }.should be_true
      conf.operations.each { |operation| operation.href.should =~ /^http:\/\/.*\/(#{operation.rel})$/ }
    end
  end

  describe "JSON" do
    it "can be constructed" do
      conf = CIMI::Model::MachineConfiguration.from_json(@json)
      conf.should_not be_nil
      conf.should serialize_to @json, :fmt => :json
    end

    it "should have default properties" do
      conf = CIMI::Model::MachineConfiguration.from_json(@json)
      conf.name.should == 'MachineConfiguration1'
      conf.uri == 'http://cimi.example.org/machine_configurations/1'
      conf.description == 'Example MachineConfiguration One'
      conf.created.should == "2011-11-14"
    end

    it "should have cpu and memory properties" do
      conf = CIMI::Model::MachineConfiguration.from_json(@json)
      conf.cpu.should == "2"
      conf.memory.should be_an_instance_of Hash
      conf.memory['quantity'].should == '1'
      conf.memory['units'].should == 'gigabyte'
    end

    it "should have disk array property with capacity" do
      conf = CIMI::Model::MachineConfiguration.from_json(@json)
      conf.disk.should be_an_instance_of Array
      conf.disk.size.should > 0
      conf.disk[0].should respond_to :capacity
      conf.disk[0].capacity.size.should == 1
      conf.disk[0].capacity[0]['format'] == 'ext4'
      conf.disk[0].capacity[0]['quantity'] == '1'
      conf.disk[0].capacity[0]['attachmentPoint'] == '/'
      conf.disk[0].capacity[0]['units'] == 'terabyte'
    end

    it "should have edit and delete operations" do
      conf = CIMI::Model::MachineConfiguration.from_json(@json)
      conf.operations.size.should == 2
      conf.operations.any? { |operation| operation.rel == 'edit' }.should be_true
      conf.operations.any? { |operation| operation.rel == 'delete' }.should be_true
      conf.operations.each { |operation| operation.href.should =~ /^http:\/\/.*\/(#{operation.rel})$/ }
    end

  end
end
