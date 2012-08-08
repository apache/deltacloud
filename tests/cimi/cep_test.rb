#
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

$:.unshift File.join(File.dirname(__FILE__))

require "test_helper.rb"

describe "CIMI Entry Point" do
  include CIMI::Test::Methods

  describe "XML form" do
    # Cache the response for all assertions
    res = cep(:accept => :xml)

    it "should set the proper content type" do
      res.headers[:content_type].must_equal "application/xml"
    end

    it "should use CloudEntryPoint as the XML root" do
      res.xml.root.name.must_equal "CloudEntryPoint"
      names = res.xml.xpath("/c:CloudEntryPoint", api.ns).map { |e| e.name }
      names.must_equal ["CloudEntryPoint"]
    end

    it "should have an id equal to the CEP URL" do
      (res.xml/"CloudEntryPoint/id").text.must_equal api.cep_url
    end

  end

  describe "JSON form" do
    # Cache the response for all assertions
    res = cep(:accept => :json)

    it "should set the proper content type" do
      res.headers[:content_type].must_equal "application/json"
    end

    it "should return JSON if asked to" do
      res.headers[:content_type].must_equal "application/json"
      res.json["id"].must_equal api.cep_url
    end
  end
end
