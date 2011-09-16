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

require 'deltacloud/drivers'
require 'deltacloud/drivers/mock/mock_driver'

module DeltacloudUnitTest
  class ApiTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def setup
      @app ||= Sinatra::Application
      @driver ||= Deltacloud::Drivers::Mock::MockDriver.new
    end

    def teardown
      @app = nil
      @driver = nil
    end

    def test_params
      op = @app.collections[:instances].operations[:create]
      op.params.keys =~ [:realm_id, :image_id, :hwp_id]
    end

    def test_effective_params
      features = @driver.features(:instances).collect { |f| f.name }
      features.should =~ [:hardware_profiles, :user_name, :authentication_key, :user_data]

      op = @app.collections[:instances].operations[:create]
      op.effective_params(@driver).keys.should =~ [:image_id, :hwp_memory, :hwp_id, :keyname, :name, :hwp_storage, :realm_id, :user_data]

      op.params.keys =~ [:realm_id, :image_id, :hwp_id]
    end
  end
end
