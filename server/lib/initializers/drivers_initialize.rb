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

require_relative './../deltacloud/drivers'
require_relative './../deltacloud/models'
require_relative './../deltacloud/helpers/driver_helper'

Deltacloud::Drivers.driver_config.each_key do |driver_name|
  require_relative File.join('..', 'deltacloud', 'drivers', driver_name.to_s, driver_name.to_s + '_driver.rb')
end

puts "#{Deltacloud::Drivers.driver_config.size} cloud providers loaded."
