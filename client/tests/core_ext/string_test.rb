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

require_relative '../test_helper'

describe String do

  it 'support #to_xml' do
    "".must_respond_to :to_xml
    "<root></root>".to_xml.must_be_kind_of Nokogiri::XML::Document
    "<root></root>".to_xml.root.must_be_kind_of Nokogiri::XML::Element
    "<root></root>".to_xml.root.name.must_equal 'root'
  end

  it 'support #camelize' do
    "".must_respond_to :camelize
    "test".camelize.must_equal 'Test'
    "foo_bar".camelize.must_equal 'FooBar'
  end

  it 'support #pluralize' do
    ''.must_respond_to :pluralize
    "test".pluralize.must_equal 'tests'
    "address".pluralize.must_equal 'addresses'
    "entity".pluralize.must_equal 'entities'
  end

  it 'support #singularize' do
    ''.must_respond_to :singularize
    'tests'.singularize.must_equal 'test'
    'addresses'.singularize.must_equal 'address'
    'entity'.singularize.must_equal 'entity'
  end

end
