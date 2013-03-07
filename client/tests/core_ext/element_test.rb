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

describe Nokogiri::XML::Element do

  before do
    mock_xml = Nokogiri::XML(
      '<root><test id="1"><inner id="2">VALUE</inner><r></r></test></root>'
    )
    @mock_el = mock_xml.root
  end

  it 'support #text_at' do
    @mock_el.text_at('test/inner').must_equal 'VALUE'
    @mock_el.text_at('test/unknown').must_be_nil
    @mock_el.text_at('test/r').must_equal ''
  end

  it 'support #attr_at' do
    @mock_el.attr_at('test', :id).must_equal '1'
    @mock_el.attr_at('test', 'id').must_equal '1'
    @mock_el.attr_at('test/inner', 'id').must_equal '2'
    @mock_el.attr_at('r', 'id').must_be_nil
  end

end
