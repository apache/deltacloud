# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless require_relatived by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.
#
module CIMI
  module Model; end
end

require 'require_relative' if RUBY_VERSION < '1.9'

require_relative './models/schema'
require_relative './models/base'
require_relative './models/collection'
require_relative './models/errors'
require_relative './models/action'
require_relative './models/disk'
require_relative './models/disk_collection'
require_relative './models/machine_volume'
require_relative './models/machine_volume_collection'

# Toplevel entities; order matters as it determines the order
# in which the entities appear in the CEP
require_relative './models/cloud_entry_point'
require_relative './models/resource_metadata'
require_relative './models/machine'
require_relative './models/machine_template'
require_relative './models/machine_configuration'
require_relative './models/machine_image'
require_relative './models/credential'
require_relative './models/volume'
require_relative './models/volume_template'
require_relative './models/volume_configuration'
require_relative './models/volume_image'
require_relative './models/network'
require_relative './models/network_template'
require_relative './models/network_configuration'
require_relative './models/network_port'
require_relative './models/network_port_template'
require_relative './models/network_port_configuration'
require_relative './models/address'
require_relative './models/address_template'
require_relative './models/routing_group'
require_relative './models/routing_group_template'
