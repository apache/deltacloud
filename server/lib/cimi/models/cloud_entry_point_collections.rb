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


class CIMI::Model::CloudEntryPoint < CIMI::Model::Base

  # All possible CIMI collections, in the order in which they should appear
  # in the CEP
  COLLECTIONS = {
    "resourceMetadata" => CIMI::Model::ResourceMetadata,
    "systems" => CIMI::Model::System,
    "systemTemplates" => CIMI::Model::SystemTemplate,
    "machines" => CIMI::Model::Machine,
    "machineTemplates" => CIMI::Model::MachineTemplate,
    "machineImages" => CIMI::Model::MachineImage,
    "credentials" => CIMI::Model::Credential,
    "credentialTemplates" => CIMI::Model::CredentialTemplate,
    "volumes" => CIMI::Model::Volume,
    "volumeTemplates" => CIMI::Model::VolumeTemplate,
    "volumeImages" => CIMI::Model::VolumeImage,
    "networks" => CIMI::Model::Network,
    "networkTemplates" => CIMI::Model::NetworkTemplate,
    "networkPorts" => CIMI::Model::NetworkPort,
    "networkPortTemplates" => CIMI::Model::NetworkTemplate,
    "addresses" => CIMI::Model::Address,
    "addressTemplates" => CIMI::Model::AddressTemplate,
    "forwardingGroups" => CIMI::Model::ForwardingGroup,
    "forwardingGroupTemplates" => CIMI::Model::ForwardingGroupTemplate,
    "volumeConfigurations" => CIMI::Model::VolumeConfiguration,
    "machineConfigurations" => CIMI::Model::MachineConfiguration,
    "networkConfigurations" => CIMI::Model::NetworkConfiguration,
    "networkPortConfigurations" => CIMI::Model::NetworkPortConfiguration,
    "jobs" =>  nil,
    "meters" => nil,
    "meterTemplates" => nil,
    "meterConfigs" => nil,
    "eventLogs" => nil,
    "eventLogTemplates" => nil
  }

  COLLECTIONS.each do |coll|
    coll_entry = coll
    collection coll_entry[0].underscore.to_sym, :class => coll_entry[1] unless coll_entry[1] == nil
  end

end
