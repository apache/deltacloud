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
  module Service
    def self.root_entities
      CIMI::Model::root_entities.map do |m|
        CIMI::Service.const_get(m.name.split('::').last)
      end
    end
  end
end

require_relative './models'
require_relative './../db/provider'
require_relative './../db/entity'
require_relative './../db/machine_template'
require_relative './../db/address_template'
require_relative './../db/volume_configuration'
require_relative './../db/volume_template'

require_relative './service/base'
require_relative './service/machine'
require_relative './service/machine_image'
require_relative './service/volume_image'
require_relative './service/system_template'
require_relative './service/network_port_configuration'
require_relative './service/credential_create'
require_relative './service/machine_template_create'
require_relative './service/volume_create'
require_relative './service/network_create'
require_relative './service/network'
require_relative './service/forwarding_group'
require_relative './service/volume_template_create'
require_relative './service/system_machine'
require_relative './service/system_volume'
require_relative './service/system_network'
require_relative './service/system_forwarding_group'
require_relative './service/system_network_port'
require_relative './service/system_address'
require_relative './service/system_credential'
require_relative './service/system_system'
require_relative './service/system'
require_relative './service/system_create'
require_relative './service/address_template_create'
require_relative './service/volume'
require_relative './service/volume_image_create'
require_relative './service/machine_configuration'
require_relative './service/volume_template'
require_relative './service/machine_template'
require_relative './service/network_port'
require_relative './service/forwarding_group_template'
require_relative './service/credential_template'
require_relative './service/volume_configuration'
require_relative './service/cloud_entry_point'
require_relative './service/network_configuration'
require_relative './service/address_template'
require_relative './service/action'
require_relative './service/machine_create'
require_relative './service/address'
require_relative './service/credential'
require_relative './service/network_port_template'
require_relative './service/machine_image_create'
require_relative './service/address_create'
require_relative './service/network_template'
require_relative './service/disk'
require_relative './service/machine_volume'
require_relative './service/resource_metadata'
