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

# JoeV - If I don't include these here the associated CIMI::Service::<x>
# JoeV   class referenced below is undefined even though these are specified
# JoeV   in service.rb.
require_relative './resource_metadata'
require_relative './credential'
require_relative './network_template'
require_relative './network_port_template'
require_relative './address'
require_relative './address_template'

class CIMI::Service::CloudEntryPoint < CIMI::Service::Base

  metadata :driver, :type => 'text'
  metadata :provider, :type => 'text'

  SERVICES = {
    "resource_metadata" => CIMI::Service::ResourceMetadata,
    "systems" =>  CIMI::Service::System,
    "system_templates" => CIMI::Service::SystemTemplate,
    "machines" => CIMI::Service::Machine,
    "machine_templates" => CIMI::Service::MachineTemplate,
    "machine_configurations" => CIMI::Service::MachineConfiguration,
    "machine_images" => CIMI::Service::MachineImage,
    "credentials" => CIMI::Service::Credential,
    "volumes" => CIMI::Service::Volume,
    "volume_templates" => CIMI::Service::VolumeTemplate,
    "volume_configurations" => CIMI::Service::VolumeConfiguration,
    "volume_images" => CIMI::Service::VolumeImage,
    "networks" =>  CIMI::Service::Network,
    "network_templates" => CIMI::Service::NetworkTemplate,
    "network_configurations" => CIMI::Service::NetworkPortConfiguration,
    "network_port_template" =>  CIMI::Service::NetworkPortTemplate,
    "network_port_configurations" => CIMI::Service::NetworkPortConfiguration,
    "addresses" => CIMI::Service::Address,
    "address_templates" =>  CIMI::Service::AddressTemplate,
    "forwarding_groups" => CIMI::Service::ForwardingGroup,
    "forwarding_group_templates" => CIMI::Service::ForwardingGroupTemplate
  }

  def initialize(context)
    super(context, :values => {
      :name => context.driver.name,
      :description => "Cloud Entry Point for the Deltacloud #{context.driver.name} driver",
      :driver => context.driver.name,
      :provider => context.current_provider,
      :id => context.cloudEntryPoint_url,
      :base_uri => context.base_uri + "/",
      :created => Time.now.xmlschema
    })
    fill_entities context
  end

  private
  def fill_entities(context)
    CIMI::Collections.modules(:cimi).inject({}) do |supported_entities, m|
      m.collections.each do |c|
        if c.operation(:index).nil?
          warn "#{c} does not have :index operation."
          next
        end
        if c.collection_name == :cloudEntryPoint
          warn "#{c} is cloudEntryPoint"
          next
        end

        index_operation_capability = c.operation(:index).required_capability
        next if  m.settings.respond_to?(:capability) and \
                !m.settings.capability(index_operation_capability)

        coll = self[c.collection_name]
        coll.href = context.send(:"#{c.collection_name.to_s}_url")

        if context.expand? c.collection_name.to_s.camelize(:lower).to_sym
          coll[c.collection_name] = \
            SERVICES[c.collection_name.to_s].find(:all, context)
        end

      end
    end
  end

end

