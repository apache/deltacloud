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
describe "MachineTemplate model" do

  before(:all) do
    @xml = IO::read(File::join(DATA_DIR, "machine_template.xml"))
    @json = IO::read(File::join(DATA_DIR, "machine_template.json"))
  end

  describe 'XML' do
    it "can be constructed" do
      templ = CIMI::Model::MachineTemplate.from_xml(@xml)
      templ.should_not be_nil
      templ.should serialize_to @xml, :fmt => :xml
    end

    it "should have default properties" do
      templ = CIMI::Model::MachineTemplate.from_xml(@xml)
      templ.created.should == "2011-11-01"
      templ.name.should == "My First Template"
      templ.description.should == "A template for testing"
      templ.uri.should == "http://cimi.example.org/machine_templates/1"
    end

    it "should convert strings in keys to symbols when contructed from XML" do
      templ = CIMI::Model::MachineTemplate.from_xml(@xml)
      templ.should_not be_nil
      templ.attribute_values.keys.each { |key| key.should be_a_kind_of(Symbol) }
    end

    it "should reference machine_config" do
      templ = CIMI::Model::MachineTemplate.from_xml(@xml)
      templ.machine_config.should be_an_instance_of Struct::CIMI_MachineConfig
      templ.machine_config.href.should == "http://cimi.example.org/machine_configs/1"
    end

    it "should reference machine_image" do
      templ = CIMI::Model::MachineTemplate.from_xml(@xml)
      templ.machine_image.should be_an_instance_of Struct::CIMI_MachineImage
      templ.machine_image.href.should == "http://cimi.example.org/machine_images/1"
    end

    it "should have list of attached volumes" do
      templ = CIMI::Model::MachineTemplate.from_xml(@xml)
      templ.volumes.should be_a_kind_of Array
      templ.volumes.each do |volume|
        volume.href.should =~ /^http:\/\/.*\/volumes\/(\w+)$/
        volume.protocol.should == 'nfs'
        volume.attachment_point == '/dev/sda'
        volume.should be_an_instance_of Struct::CIMI_Volume
      end
    end

    it "should have list of network interfaces" do
      templ = CIMI::Model::MachineTemplate.from_xml(@xml)
      templ.network_interfaces.should be_an_instance_of Array
      templ.network_interfaces.each do |interface|
        interface.hostname == 'host.cimi.example.org'
        interface.mac_address == '00:11:22:33:44:55'
        interface.state == 'UP'
        interface.protocol == 'TCP'
        interface.allocation == 'static'
        interface.address == '192.168.0.17'
        interface.default_gateway == '192.168.0.1'
        interface.dns == '192.168.0.1'
        interface.max_transmission_unit == '1500'
        interface.vsp.should_not be_nil
        interface.vsp.should be_an_instance_of Struct::CIMI_Vsp
        interface.vsp.href.should =~ /^http:\/\/.*\/vsps\/(\w+)$/
        interface.should be_an_instance_of Struct::CIMI_NetworkInterface
      end
    end

    it "should have edit and delete operations" do
      templ = CIMI::Model::MachineTemplate.from_xml(@xml)
      templ.operations.size.should == 2
      templ.operations.any? { |operation| operation.rel == 'edit' }.should be_true
      templ.operations.any? { |operation| operation.rel == 'delete' }.should be_true
      templ.operations.each { |operation| operation.href.should =~ /^http:\/\/.*\/(#{operation.rel})$/ }
    end

  end

  describe 'JSON' do
    it "can be constructed" do
      templ = CIMI::Model::MachineTemplate.from_json(@json)
      templ.should_not be_nil
      templ.should serialize_to @xml, :fmt => :xml
    end

    it "should have default properties" do
      templ = CIMI::Model::MachineTemplate.from_json(@json)
      templ.created.should == "2011-11-01"
      templ.name.should == "My First Template"
      templ.description.should == "A template for testing"
      templ.uri.should == "http://cimi.example.org/machine_templates/1"
    end

    it "should convert strings in keys to symbols when contructed from XML" do
      templ = CIMI::Model::MachineTemplate.from_json(@json)
      templ.should_not be_nil
      templ.attribute_values.keys.each { |key| key.should be_a_kind_of(Symbol) }
    end

    it "should reference machine_config" do
      templ = CIMI::Model::MachineTemplate.from_json(@json)
      templ.machine_config.should be_an_instance_of Struct::CIMI_MachineConfig
      templ.machine_config.href.should == "http://cimi.example.org/machine_configs/1"
    end

    it "should reference machine_image" do
      templ = CIMI::Model::MachineTemplate.from_json(@json)
      templ.machine_image.should be_an_instance_of Struct::CIMI_MachineImage
      templ.machine_image.href.should == "http://cimi.example.org/machine_images/1"
    end

    it "should have list of attached volumes" do
      templ = CIMI::Model::MachineTemplate.from_json(@json)
      templ.volumes.should be_a_kind_of Array
      templ.volumes.each do |volume|
        volume.href.should =~ /^http:\/\/.*\/volumes\/(\w+)$/
        volume.protocol.should == 'nfs'
        volume.attachment_point == '/dev/sda'
        volume.should be_an_instance_of Struct::CIMI_Volume
      end
    end

    it "should have list of network interfaces" do
      templ = CIMI::Model::MachineTemplate.from_json(@json)
      templ.network_interfaces.should be_an_instance_of Array
      templ.network_interfaces.each do |interface|
        interface.hostname == 'host.cimi.example.org'
        interface.mac_address == '00:11:22:33:44:55'
        interface.state == 'UP'
        interface.protocol == 'TCP'
        interface.allocation == 'static'
        interface.address == '192.168.0.17'
        interface.default_gateway == '192.168.0.1'
        interface.dns == '192.168.0.1'
        interface.max_transmission_unit == '1500'
        interface.vsp.should_not be_nil
        interface.vsp.should be_an_instance_of Struct::CIMI_Vsp
        interface.vsp.href.should =~ /^http:\/\/.*\/vsps\/(\w+)$/
        interface.should be_an_instance_of Struct::CIMI_NetworkInterface
      end
    end

    it "should have edit and delete operations" do
      templ = CIMI::Model::MachineTemplate.from_json(@json)
      templ.operations.size.should == 2
      templ.operations.any? { |operation| operation.rel == 'edit' }.should be_true
      templ.operations.any? { |operation| operation.rel == 'delete' }.should be_true
      templ.operations.each { |operation| operation.href.should =~ /^http:\/\/.*\/(#{operation.rel})$/ }
    end

  end

end
