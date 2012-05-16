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

unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

require_relative './models/schema'
require_relative './models/base'
require_relative './models/errors'
require_relative './models/entity_metadata'
require_relative './models/entity_metadata_collection'
require_relative './models/cloud_entry_point'
require_relative './models/machine_template'
require_relative './models/machine_image'
require_relative './models/machine_configuration'
require_relative './models/action'
require_relative './models/machine'
require_relative './models/volume'
require_relative './models/machine_admin'
require_relative './models/volume_configuration'
require_relative './models/volume_image'
require_relative './models/volume_template'
require_relative './models/machine_template_collection'
require_relative './models/machine_image_collection'
require_relative './models/machine_configuration_collection'
require_relative './models/machine_collection'
require_relative './models/volume_collection'
require_relative './models/machine_admin_collection'
require_relative './models/volume_configuration_collection'
require_relative './models/volume_image_collection'
require_relative './models/volume_template_collection'
require_relative './models/network'
require_relative './models/network_collection'
require_relative './models/network_configuration'
require_relative './models/network_configuration_collection'
require_relative './models/network_template'
require_relative './models/network_template_collection'
require_relative './models/routing_group'
require_relative './models/routing_group_collection'
require_relative './models/routing_group_template'
require_relative './models/routing_group_template_collection'
require_relative './models/vsp'
require_relative './models/vsp_collection'
require_relative './models/vsp_configuration'
require_relative './models/vsp_configuration_collection'
require_relative './models/vsp_template'
require_relative './models/vsp_template_collection'
require_relative './models/address'
require_relative './models/address_collection'
require_relative './models/address_template'
require_relative './models/address_template_collection'
