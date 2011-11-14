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

require 'spec_helper'

require 'cimi/model'

describe "Schema" do
  before(:each) do
    @schema = CIMI::Model::Schema.new
  end

  it "does not allow adding attributes after being used for conversion" do
    @schema.scalar(:before)
    @schema.from_json({})
    lambda { @schema.scalar(:after) }.should raise_error
  end

  describe "scalars" do
    before(:each) do
      @schema.scalar(:attr)
      @schema.text(:camel_hump)

      @schema.attribute_names.should == [:attr, :camel_hump]
    end

    let :sample_xml do
      parse_xml("<camelHump>bumpy</camelHump>", :keep_root => true)
    end

    it "should camel case attribute names for JSON" do
      obj = @schema.from_json("camelHump" => "bumpy")
      obj.should_not be_nil
      obj[:camel_hump].should == "bumpy"

      json = @schema.to_json(obj)
      json.should == { "camelHump" => "bumpy" }
    end

    it "should camel case attribute names for XML" do
      obj = @schema.from_xml(sample_xml)

      obj.should_not be_nil
      obj[:camel_hump].should == "bumpy"

      xml = @schema.to_xml(obj)

      xml.should == { "camelHump" => [{ "content" => "bumpy" }] }
    end

    it "should allow aliasing the XML and JSON name" do
      @schema.scalar :aliased, :xml_name => :xml, :json_name => :json
      obj = @schema.from_xml({"aliased" => "no", "xml" => "yes"}, {})
      obj[:aliased].should == "yes"

      obj = @schema.from_json({"aliased" => "no", "json" => "yes"}, {})
      obj[:aliased].should == "yes"
    end
  end

  describe "hrefs" do
    before(:each) do
      @schema.href(:meter)
    end

    it "should extract the href attribute from XML" do
      xml = parse_xml("<meter href='http://example.org/'/>")

      obj = @schema.from_xml(xml)
      check obj
      @schema.to_xml(obj).should == xml
    end

    it "should extract the href attribute from JSON" do
      json = { "meter" =>  { "href" => "http://example.org/" } }

      obj = @schema.from_json(json)
      check obj
      @schema.to_json(obj).should == json
    end

    def check(obj)
      obj.should_not be_nil
      obj[:meter].href.should == 'http://example.org/'
    end
  end

  describe "structs" do
    before(:each) do
      @schema.struct(:struct, :content => :scalar) do
        scalar   :href
      end
      @schema.attribute_names.should == [:struct]
    end

    let(:sample_json) do
      { "struct" => { "scalar" => "v1", "href" => "http://example.org/" } }
    end

    let (:sample_xml) do
      parse_xml("<struct href='http://example.org/'>v1</struct>")
    end

    let (:sample_xml_no_href) do
      parse_xml("<struct>v1</struct>")
    end

    describe "JSON conversion" do
      it "should convert empty hash" do
        model = @schema.from_json({ })
        check_empty_struct model
        @schema.to_json(model).should == {}
      end

      it "should convert empty body" do
        model = @schema.from_json({ "struct" => { } })
        check_empty_struct model
        @schema.to_json(model).should == {}
      end

      it "should convert values" do
        model = @schema.from_json(sample_json)
        check_struct model
        @schema.to_json(model).should == sample_json
      end
    end

    describe "XML conversion" do
      it "should convert empty hash" do
        model = @schema.from_xml({ })
        check_empty_struct model
        @schema.to_xml(model).should == {}
      end

      it "should convert empty body" do
        model = @schema.from_json({ "struct" => { } })
        check_empty_struct model
        @schema.to_xml(model).should == {}
      end

      it "should convert values" do
        model = @schema.from_xml(sample_xml)
        check_struct model
        @schema.to_xml(model).should == sample_xml
      end

      it "should handle missing attributes" do
        model = @schema.from_xml(sample_xml_no_href)
        check_struct model, :nil_href => true
        @schema.to_xml(model).should == sample_xml_no_href
      end
    end

    def check_struct(obj, opts = {})
      obj.should_not be_nil
      obj[:struct].should_not be_nil
      obj[:struct].scalar.should == "v1"
      if opts[:nil_href]
        obj[:struct].href.should be_nil
      else
        obj[:struct].href.should == "http://example.org/"
      end
    end

    def check_empty_struct(obj)
      obj.should_not be_nil
      obj[:struct].should_not be_nil
      obj[:struct].scalar.should be_nil
      obj[:struct].href.should be_nil
    end
  end

  describe "arrays" do
    before(:each) do
      @schema.array(:structs, :content => :scalar) do
        scalar :href
      end
    end

    let(:sample_json) do
      { "structs" => [{ "scalar" => "v1", "href" => "http://example.org/1" },
                      { "scalar" => "v2", "href" => "http://example.org/2" }] }
    end

    let (:sample_xml) do
      parse_xml("<wrapper>
  <struct href='http://example.org/1'>v1</struct>
  <struct href='http://example.org/2'>v2</struct>
</wrapper>", :keep_root => false)
    end

    it "should convert missing array from JSON" do
      obj = @schema.from_json({})

      obj.should_not be_nil
      obj[:structs].should == []
      @schema.to_json(obj).should == {}
    end

    it "should convert empty array from JSON" do
      obj = @schema.from_json("structs" => [])

      obj.should_not be_nil
      obj[:structs].should == []
      @schema.to_json(obj).should == {}
    end

    it "should convert arrays from JSON" do
      obj = @schema.from_json(sample_json)

      check_structs(obj)
      @schema.to_json(obj).should == sample_json
    end

    it "should convert arrays from XML" do
      obj = @schema.from_xml(sample_xml)

      check_structs(obj)
      @schema.to_xml(obj).should == sample_xml
    end

    def check_structs(obj)
      obj.should_not be_nil
      obj[:structs].size.should == 2
      obj[:structs][0].scalar.should == "v1"
      obj[:structs][0].href.should == "http://example.org/1"
      obj[:structs][1].scalar.should == "v2"
      obj[:structs][1].href.should == "http://example.org/2"
    end
  end

end
