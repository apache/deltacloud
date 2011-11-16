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

  it "can be constructed from XML" do
    templ = CIMI::Model::MachineTemplate.from_xml(@xml)
    templ.should_not be_nil
    templ.created.should == "2011-11-01"
    templ.volumes.size.should == 1
    templ.should serialize_to @xml, :fmt => :xml
  end

  it "should convert strings in keys to symbols when contructed from XML" do
    templ = CIMI::Model::MachineTemplate.from_xml(@xml)
    templ.should_not be_nil
    templ.attribute_values.keys.each { |key| key.should be_a(Symbol) }
  end

  it "can be constructed from JSON" do
    templ = CIMI::Model::MachineTemplate.from_json(@json)
    templ.should_not be_nil

    templ.created.should == "2011-11-01"
    templ.should serialize_to @json, :fmt => :json
  end
end
