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

# This will create the directory we use for storing Mock driver
# data and also CIMI database file
#

# By default the location is /var/tmp/deltacloud-{USER}/
#
BASE_STORAGE_DIR = File.join('/', 'var', 'tmp', "deltacloud-#{ENV['USER']}")

# The mock driver YAML files are stored in BASE_STORAGE_DIR/mock
# You can overide this by setting 'DELTACLOUD_MOCK_STORAGE' environment variable
#
MOCK_STORAGE_DIR = ENV['DELTACLOUD_MOCK_STORAGE'] || File.join(BASE_STORAGE_DIR, 'mock')

[BASE_STORAGE_DIR, MOCK_STORAGE_DIR].each do |p|
  FileUtils.mkpath(p, :mode => 0750) unless File.directory?(p)
end
