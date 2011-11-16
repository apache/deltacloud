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

describe "MachineImage model" do

  before(:all) do
    @xml = IO::read(File::join(DATA_DIR, "machine_image.xml"))
    @json = IO::read(File::join(DATA_DIR, "machine_image.json"))
  end

  describe "XML" do
    it "can be constructed" do
      img = CIMI::Model::MachineImage.from_xml(@xml)
      img.should_not be_nil
      img.should serialize_to @xml, :fmt => :xml
    end

    it "should have default properties" do
      img = CIMI::Model::MachineImage.from_xml(@xml)
      img.uri.should == "http://cimi.example.org/machine_image/1"
      img.name.should == "img1"
      img.description.should == "Machine Image One"
      img.created.should == "2011-11-14"
    end

    it "should have image location property" do
      img = CIMI::Model::MachineImage.from_xml(@xml)
      img.image_location.size == 1
      img.image_location[0]['href'].should == 'nfs://cimi.example.com/images/1.img'
    end

    it "should have edit and delete operations" do
      img = CIMI::Model::MachineImage.from_xml(@xml)
      img.operations.any? { |operation| operation.rel == 'edit' }.should be_true
      img.operations.any? { |operation| operation.rel == 'delete' }.should be_true
      img.operations.each { |operation| operation.href.should =~ /^http:\/\/.*\/(#{operation.rel})$/ }
    end

    it "should parse properties correctly in XML" do
      img = CIMI::Model::MachineImage.from_xml(@xml)
      img.property.any? { |p| p.name == 'status' }.should be_true
      img.property.any? { |p| p.name == 'locked' }.should be_true
      img.property.size.should == 2
    end

    it "should convert strings in keys to symbols when contructed from XML" do
      imgl = CIMI::Model::MachineImage.from_xml(@xml)
      imgl.should_not be_nil
      imgl.attribute_values.keys.each { |key| key.should be_a_kind_of(Symbol) }
    end
  end

  describe 'JSON' do
    it "can be constructed" do
      img = CIMI::Model::MachineImage.from_json(@json)
      img.should_not be_nil
      img.should serialize_to @json, :fmt => :json
    end

    it "should have default properties" do
      img = CIMI::Model::MachineImage.from_json(@json)
      img.uri.should == "http://cimi.example.org/machine_images/1"
      img.name.should == "img1"
      img.description.should == "Machine Image One"
      img.created.should == "2011-11-14"
    end

    it "should have image location property" do
      img = CIMI::Model::MachineImage.from_json(@json)
      img.image_location.size == 1
      img.image_location[0]['href'].should == 'nfs://cimi.example.com/images/1.img'
    end

    it "should have edit and delete operations" do
      img = CIMI::Model::MachineImage.from_json(@json)
      img.operations.any? { |operation| operation.rel == 'edit' }.should be_true
      img.operations.any? { |operation| operation.rel == 'delete' }.should be_true
      img.operations.each { |operation| operation.href.should =~ /^http:\/\/.*\/(#{operation.rel})$/ }
    end

    it "should parse properties correctly in XML" do
      img = CIMI::Model::MachineImage.from_json(@json)
      img.property.any? { |p| p.name == 'status' }.should be_true
      img.property.any? { |p| p.name == 'locked' }.should be_true
      img.property.size.should == 2
    end
  end

end
