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

require 'nokogiri'
require 'json'

describe "Collection class" do

  BASE_URL = "http://example.com/cimi"
  COLL_URL = BASE_URL + "/models"

  class Model < CIMI::Model::Base
    scalar :text
  end

  class Container < CIMI::Model::Base
    collection :models, :class => Model
  end

  before do
    @models = ["m1", "m2"].map { |s| Model.new(:text => s) }
    @xml = IO::read(File::join(DATA_DIR, "container.xml"))
    @json = IO::read(File::join(DATA_DIR, "container.json"))
  end

  describe "XML serialization" do
    it "empty collection only has href" do
      cont = Container.new(:id => BASE_URL)
      doc = to_dom(cont)

      (doc/"/c:Container/c:models/@href").text.must_equal COLL_URL
      (doc/"/c:Container/c:models/c:id").size.must_equal 0
    end

    it "contains count of models" do
      cont = Container.new(:id => BASE_URL, :models => @models)
      doc = to_dom(cont)

      (doc/"/c:Container/c:models/c:count").text.must_equal "2"
      (doc/"/c:Container/c:models/c:Model").size.must_equal 2
    end
  end

  describe "JSON serialization" do
    it "empty collection only has href" do
      cont = Container.new(:id => BASE_URL)
      json = to_json(cont)

      json["models"]["href"].must_equal COLL_URL
      json["models"].keys.must_equal ["href"]
    end

    it "contains count of models" do
      cont = Container.new(:id => BASE_URL, :models => @models)
      json = to_json(cont)

      json["models"]["count"].must_equal 2
      json["models"]["models"].size.must_equal 2
    end
  end

  it "deserializes from XML" do
    cont = Container.from_xml(@xml)
    cont.id.must_equal BASE_URL
    cont.models.count.must_equal "2"
    cont.models.entries.size.must_equal 2
    cont.models.entries[0].text.must_equal "m1"
    cont.models.entries[1].text.must_equal "m2"
  end

  it "deserializes from JSON" do
    cont = Container.from_json(@json)
    cont.id.must_equal BASE_URL
    # FIXME: This is a very annoying difference between XML and JSON; in XML
    # all scalars are strings, in JSON, strings that look like integers are
    # converted to integer objects
    cont.models.count.must_equal 2
    cont.models.entries.size.must_equal 2
    cont.models.entries[0].text.must_equal "m1"
    cont.models.entries[1].text.must_equal "m2"
  end

  def to_dom(model)
    doc = Nokogiri::XML(model.to_xml)
    doc.root.add_namespace("c", doc.namespaces["xmlns"])
    doc
  end

  def to_json(model)
    JSON.parse(model.to_json)
  end
end
