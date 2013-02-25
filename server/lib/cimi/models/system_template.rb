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

class CIMI::Model::SystemTemplate < CIMI::Model::Base

  acts_as_root_entity

  array :component_descriptors do
    text :name, :description
    hash_map :properties
    text :type, :required => true

    #component_template, comprises:
    ref :machine_template, :class => CIMI::Model::MachineTemplate
    ref :system_template, :class => CIMI::Model::SystemTemplate
    ref :credential_template, :class => CIMI::Model::CredentialTemplate
    ref :volume_template, :class => CIMI::Model::VolumeTemplate
    ref :network_template, :class => CIMI::Model::NetworkTemplate
    ref :network_port_template, :class => CIMI::Model::NetworkPortTemplate
    ref :forwarding_group_template, :class => CIMI::Model::ForwardingGroupTemplate
    ref :address_template, :class => CIMI::Model::AddressTemplate
    text :quantity
  end

  #  array :meter_templates do
  #    scalar :href
  #  end

  #  href :event_log_template

  array :operations do
    scalar :rel, :href
  end

end
