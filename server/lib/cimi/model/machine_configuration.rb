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

  struct :memory do
    scalar :quantity
    scalar :units
  end

  text :cpu

  array :disks do
    struct :capacity do
      scalar :quantity
      scalar :units
    end
    scalar :format
    scalar :attachment_point
  end

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, _self)
    profiles = []
    if id == :all
      profiles = _self.driver.hardware_profiles(_self.credentials)
      profiles.map { |profile| from_hardware_profile(profile, _self) }.compact
    else
      profile = _self.driver.hardware_profile(_self.credentials, id)
      from_hardware_profile(profile, _self)
    end
  end

  private

  def self.from_hardware_profile(profile, _self)
    # We accept just profiles with all properties set
    return unless profile.memory or profile.cpu or profile.storage
    machine_hash = {
      :name => profile.name,
      :description => "Machine Configuration with #{profile.memory.value} #{profile.memory.unit} "+
        "of memory and #{profile.cpu.value} CPU",
      :cpu => profile.cpu.value,
      :created => Time.now.to_s,  # FIXME: DC hardware_profile has no mention about created_at
      :memory => { :quantity => profile.memory.value, :units => profile.memory.unit },
      :disks => [ { :capacity => { :quantity => profile.storage.value, :units => profile.storage.unit } } ],
      :uri => _self.machine_configuration_url(profile.name)
    }
    self.new(machine_hash)
  end

end
