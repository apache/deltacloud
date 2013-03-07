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

describe Deltacloud::Client::Helpers::XmlHelper do

  include Deltacloud::Client::Helpers::XmlHelper

  before do
    VCR.insert_cassette(__name__)
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #extract_xml_body using string' do
    extract_xml_body("test").must_be_kind_of String
  end

  it 'supports #extract_xml_body using faraday connection' do
    result = extract_xml_body(new_client.connection.get('/api'))
    result.must_be_kind_of String
    result.wont_be_empty
  end

  it 'supports #extract_xml_body using nokogiri::document' do
    result = extract_xml_body(
      Nokogiri::XML(new_client.connection.get('/api').body)
    )
    result.must_be_kind_of String
    result.wont_be_empty
  end

  it 'supports #extract_xml_body using nokogiri::element' do
    result = extract_xml_body(
      Nokogiri::XML(new_client.connection.get('/api').body).root
    )
    result.must_be_kind_of String
    result.wont_be_empty
  end

end
