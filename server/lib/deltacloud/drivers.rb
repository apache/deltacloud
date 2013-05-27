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

require_relative 'drivers/exceptions'
require_relative 'drivers/base_driver'
require_relative 'drivers/features'

module Deltacloud
  module Drivers

    def self.driver_config
      if Thread::current[:drivers].nil?
        Thread::current[:drivers] = {}
        top_srcdir = File.join(File.dirname(__FILE__), '..', '..')
        Dir[File.join(top_srcdir, 'config', 'drivers', '*.yaml')].each do |driver_file|
          Thread::current[:drivers].merge!(YAML::load_file(driver_file))
        end
      end
      Thread::current[:drivers]
    end

  end
end
