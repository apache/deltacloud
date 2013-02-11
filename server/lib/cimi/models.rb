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
  module Model
    def self.register_as_root_entity!(klass, opts = {})
      @root_entities ||= [CIMI::Model::CloudEntryPoint]
      @root_entities << klass
      name = klass.name.split("::").last.pluralize
      unless CIMI::Model::CloudEntryPoint.href_defined?(name)
        params = {}
        if opts[:as]
          params[:xml_name] = params[:json_name] = opts[:as]
        end
        CIMI::Model::CloudEntryPoint.send(:href, name.underscore, params)
      end
    end

    def self.root_entities
      @root_entities || []
    end
  end
end

require 'require_relative' if RUBY_VERSION < '1.9'

# Database entities
#
require_relative './../db/provider'
require_relative './../db/entity'
require_relative './../db/machine_template'
require_relative './../db/address_template'
require_relative './../db/volume_configuration'
require_relative './../db/volume_template'

require_relative './models/schema'
require_relative './models/resource'
require_relative './models/collection'
require_relative './models/base'
require_relative './models/errors'
require_relative './models/action'
require_relative './models/machine_volume'
require_relative './models/disk'

require_relative './models/resource_metadata'
require_relative './models/cloud_entry_point'

CIMI::Model::ResourceMetadata.acts_as_root_entity

require_relative './models/credential'
require_relative './models/volume'
require_relative './models/volume_template'
require_relative './models/volume_configuration'
require_relative './models/volume_image'
require_relative './models/machine'
require_relative './models/machine_configuration'
require_relative './models/machine_image'
require_relative './models/machine_template'
require_relative './models/machine_template_create'
require_relative './models/machine_create'
require_relative './models/network_port'
require_relative './models/network'
require_relative './models/network_template'
require_relative './models/network_configuration'
require_relative './models/network_port_template'
require_relative './models/network_port_configuration'
require_relative './models/address'
require_relative './models/address_template'
require_relative './models/forwarding_group'
require_relative './models/forwarding_group_template'
require_relative './models/system_template'
require_relative './models/system'
require_relative './models/network_template'
require_relative './models/network_create'
