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

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/common'
require 'nokogiri'

module CimiUnitTest
  class MachineTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    #setup the url to access a machine. this will be used by all the test cases in this class
    def setup
      if @checked.nil?
        get_url '/cimi/cloudEntryPoint'
        machines = (last_xml_response/'CloudEntryPoint/machines')
        if machines
          get_auth_url machines.attr('href')
          elements = last_xml_response/'MachineCollection/machine'
          if elements.size > 0
            @access_url = elements[0].attr('href')
          end
        end
        @checked = true
      end
    end

    def test_machine_read_to_xml
      if @access_url
        get_auth_url @access_url, {}, :format => :xml
        last_response.status.should == 200
      end
    end

    def test_machine_read_to_json
      if @access_url
        get_auth_url @access_url, {}, :format => :json
        last_response.status.should == 200
      end
    end

  end
end
