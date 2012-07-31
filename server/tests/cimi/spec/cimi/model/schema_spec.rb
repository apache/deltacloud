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

require_relative '../../spec_helper.rb' if require 'minitest/autorun'

describe "Schema" do
  before do
    @schema = CIMI::Model::Schema.new
  end

  it "does not allow adding attributes after being used for conversion" do
    @schema.scalar(:before)
    @schema.from_json({})
    lambda { @schema.scalar(:after) }.must_raise RuntimeError, 'The schema has already been used to convert objects'
  end

  describe "scalars" do
    before(:each) do
      @schema.scalar(:attr)
      @schema.text(:camel_hump)

      @schema.attribute_names.must_equal [:attr, :camel_hump]
    end

    let :sample_xml do
      parse_xml("<camelHump>bumpy</camelHump>", :keep_root => true)
    end

    it "should camel case attribute names for JSON" do
      obj = @schema.from_json("camelHump" => "bumpy")
      obj.wont_be_nil
      obj[:camel_hump].must_equal "bumpy"

      json = @schema.to_json(obj)
      json['camelHump'].must_equal "bumpy"
    end

    it "should camel case attribute names for XML" do
      obj = @schema.from_xml(sample_xml)

      obj.wont_be_nil
      obj[:camel_hump].must_equal "bumpy"

      xml = @schema.to_xml(obj)

      xml['camelHump'].must_equal [{ "content" => "bumpy" }]
    end

    it "should allow aliasing the XML and JSON name" do
      @schema.scalar :aliased, :xml_name => :xml, :json_name => :json
      obj = @schema.from_xml({"aliased" => "no", "xml" => "yes"}, {})
      obj[:aliased].must_equal "yes"

      obj = @schema.from_json({"aliased" => "no", "json" => "yes"}, {})
      obj[:aliased].must_equal "yes"
    end
  end

  describe "hrefs" do
    before do
      @schema.href(:meter)
    end

    it "should extract the href attribute from XML" do
      xml = parse_xml("<meter href='http://example.org/'/>")

      obj = @schema.from_xml(xml)
      check obj
      @schema.to_xml(obj).must_equal xml
    end

    it "should extract the href attribute from JSON" do
      json = { "meter" =>  { "href" => "http://example.org/" } }

      obj = @schema.from_json(json)
      check obj
      @schema.to_json(obj).must_equal json
    end

    def check(obj)
      obj.wont_be_nil
      obj[:meter].href.must_equal 'http://example.org/'
    end
  end

  describe "structs" do
    before do
      @schema.struct(:struct, :content => :scalar) do
        scalar   :href
      end
      @schema.attribute_names.must_equal [:struct]
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
        @schema.to_json(model).keys.must_be_empty
      end

      it "should convert empty body" do
        model = @schema.from_json({ "struct" => { } })
        check_empty_struct model
        @schema.to_json(model).keys.must_be_empty
      end

      it "should convert values" do
        model = @schema.from_json(sample_json)
        check_struct model
        @schema.to_json(model).must_equal sample_json
      end
    end

    describe "XML conversion" do
      it "should convert empty hash" do
        model = @schema.from_xml({ })
        check_empty_struct model
        @schema.to_xml(model).keys.must_be_empty
      end

      it "should convert empty body" do
        model = @schema.from_json({ "struct" => { } })
        check_empty_struct model
        @schema.to_xml(model).keys.must_be_empty
      end

      it "should convert values" do
        model = @schema.from_xml(sample_xml)
        check_struct model
        @schema.to_xml(model).must_equal sample_xml
      end

      it "should handle missing attributes" do
        model = @schema.from_xml(sample_xml_no_href)
        check_struct model, :nil_href => true
        @schema.to_xml(model).must_equal sample_xml_no_href
      end
    end

    def check_struct(obj, opts = {})
      obj.wont_be_nil
      obj[:struct].wont_be_nil
      obj[:struct].scalar.must_equal "v1"
      if opts[:nil_href]
        obj[:struct].href.must_be_nil
      else
        obj[:struct].href.must_equal "http://example.org/"
      end
    end

    def check_empty_struct(obj)
      obj.wont_be_nil
      obj[:struct].wont_be_nil
      obj[:struct].scalar.must_be_nil
      obj[:struct].href.must_be_nil
    end
  end

  describe "arrays" do
    before do
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

      obj.wont_be_nil
      obj[:structs].must_be_empty
      @schema.to_json(obj).keys.must_be_empty
    end

    it "should convert empty array from JSON" do
      obj = @schema.from_json("structs" => [])

      obj.wont_be_nil
      obj[:structs].must_be_empty
      @schema.to_json(obj).keys.must_be_empty
    end

    it "should convert arrays from JSON" do
      obj = @schema.from_json(sample_json)

      check_structs(obj)
      @schema.to_json(obj).must_equal sample_json
    end

    it "should convert arrays from XML" do
      obj = @schema.from_xml(sample_xml)

      check_structs(obj)
      @schema.to_xml(obj).must_equal sample_xml
    end

    def check_structs(obj)
      obj.wont_be_nil
      obj[:structs].size.must_equal 2
      obj[:structs][0].scalar.must_equal "v1"
      obj[:structs][0].href.must_equal "http://example.org/1"
      obj[:structs][1].scalar.must_equal "v2"
      obj[:structs][1].href.must_equal "http://example.org/2"
    end
  end

end
