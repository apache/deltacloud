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

class CIMI::Model::MachineConfiguration < CIMI::Model::Base

  acts_as_root_entity :as => "machineConfigs"

  text :memory
  text :cpu

  array :disks do
    text :capacity
    text :format
    text :attachment_point
  end

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    profiles = []
    if id == :all
      profiles = context.driver.hardware_profiles(context.credentials)
      profiles.map { |profile| from_hardware_profile(profile, context) }.compact
    else
      profile = context.driver.hardware_profile(context.credentials, id)
      from_hardware_profile(profile, context)
    end
  end

  private

  def self.from_hardware_profile(profile, context)
    # We accept just profiles with all properties set
    return unless profile.memory or profile.cpu or profile.storage
    memory = profile.memory ? context.to_kibibyte((profile.memory.value || profile.memory.default), profile.memory.unit) : nil
    cpu = (profile.cpu ? (profile.cpu.value || profile.cpu.default) : nil )
    storage = profile.storage ? context.to_kibibyte((profile.storage.value || profile.storage.default), profile.storage.unit) :  nil
    machine_hash = {
      :name => profile.name,
      :description => "Machine Configuration with #{memory} KiB "+
        "of memory and #{cpu} CPU",
      :cpu => ( cpu if cpu ) ,
      :created => Time.now.xmlschema,  # FIXME: DC hardware_profile has no mention about created_at
      :memory => (memory if memory),
      :disks => (  [ { :capacity => storage  } ] if storage ),
      :id => context.machine_configuration_url(profile.name)
    }
    self.new(machine_hash)
  end

end
