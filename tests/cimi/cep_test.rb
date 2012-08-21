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

describe "CIMI Entry Point Behavior" do
  # We'd like to call this :cep, but there's already a method by that name
  model :subject, CIMI::Model::CloudEntryPoint, :cache => true do |fmt|
    cep(:accept => fmt)
  end

  it "should have an id equal to the CEP URL" do
    subject.id.must_equal api.cep_url
  end

  it "should have a baseURI" do
    subject.base_uri.must_be_uri
  end

  it "should have a name" do
    subject.name.wont_be_empty
  end
end
