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

require 'deltacloud/models/instance_address'

class CIMI::Model::Machine < CIMI::Model::Base

  text :state
  text :cpu

  struct :memory do
    scalar :quantity
    scalar :units
  end

  href :event_log

  array :disks do
    struct :capacity do
      scalar :quantity
      scalar :units
    end
    scalar :format
    scalar :attachment_point
  end

  array :volumes do
    scalar :href
    scalar :protocol
    scalar :attachment_point
  end

  array :network_interfaces do
    href :vsp
    text :hostname, :mac_address, :state, :protocol, :allocation
    text :address, :default_gateway, :dns, :max_transmission_unit
  end

  array :meters do
    scalar :href
  end

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, _self)
    instances = []
    if id == :all
      instances = _self.driver.instances(_self.credentials)
      instances.map { |instance| from_instance(instance, _self) }.compact
    else
      instance = _self.driver.instance(_self.credentials, :id => id)
      raise CIMI::Model::NotFound unless instance
      from_instance(instance, _self)
    end
  end

  def self.create_from_json(body, _self)
    json = JSON.parse(body)
    hardware_profile_id = xml['MachineTemplate']['MachineConfig']["href"].split('/').last
    image_id = xml['MachineTemplate']['MachineImage']["href"].split('/').last
    instance = _self.create_instance(_self.credentials, image_id, { :hwp_id => hardware_profile_id })
    from_instance(instance, _self)
  end

  def self.create_from_xml(body, _self)
    xml = XmlSimple.xml_in(body)
    hardware_profile_id = xml['MachineTemplate'][0]['MachineConfig'][0]["href"].split('/').last
    image_id = xml['MachineTemplate'][0]['MachineImage'][0]["href"].split('/').last
    instance = _self.driver.create_instance(_self.credentials, image_id, { :hwp_id => hardware_profile_id })
    from_instance(instance, _self)
  end

  def perform(action, _self, &block)
    begin
      if _self.driver.send(:"#{action.name}_instance", _self.credentials, self.name)
        block.callback :success
      else
        raise "Operation failed to execute on given Machine"
      end
    rescue => e
      block.callback :failure, e.message
    end
  end

  def self.delete!(id, _self)
    _self.driver.destroy_instance(_self.credentials, id)
  end

  private

  def self.from_instance(instance, _self)
    self.new(
      :name => instance.id,
      :description => instance.name,
      :uri => _self.machine_url(instance.id),
      :state => convert_instance_state(instance.state),
      :cpu => convert_instance_cpu(instance.instance_profile, _self),
      :memory => convert_instance_memory(instance.instance_profile, _self),
      :disks => convert_instance_storage(instance.instance_profile, _self),
      :network_interfaces => convert_instance_addresses(instance),
      :operations => convert_instance_actions(instance, _self)
    )
  end

  # FIXME: This will convert 'RUNNING' state to 'STARTED'
  # which is defined in CIMI (p65)
  #
  def self.convert_instance_state(state)
    ('RUNNING' == state) ? 'STARTED' : state
  end

  def self.convert_instance_cpu(profile, _self)
    cpu_override = profile.overrides.find { |p, v| p == :cpu }
    if cpu_override.nil?
      MachineConfiguration.find(profile.id, _self).cpu
    else
      cpu_override[1]
    end
  end

  def self.convert_instance_memory(profile, _self)
    machine_conf = MachineConfiguration.find(profile.name, _self)
    memory_override = profile.overrides.find { |p, v| p == :memory }
    {
      :quantity => memory_override.nil? ? machine_conf.memory[:quantity] : memory_override[1],
      :units => machine_conf.memory[:units]
    }
  end

  def self.convert_instance_storage(profile, _self)
    machine_conf = MachineConfiguration.find(profile.name, _self)
    storage_override = profile.overrides.find { |p, v| p == :storage }
    [
      { :capacity => { 
          :quantity => storage_override.nil? ? machine_conf.disks.first[:capacity][:quantity] : storage_override[1],
          :units => machine_conf.disks.first[:capacity][:units]
        } 
      } 
    ]
  end

  def self.convert_instance_addresses(instance)
    (instance.public_addresses + instance.private_addresses).collect do |address|
      {
        :hostname => address.is_hostname? ? address : nil,
        :mac_address => address.is_mac? ? address : nil,
        :state => 'Active',
        :protocol => 'IPv4',
        :address => address.is_ipv4? ? address : nil,
        :allocation => 'Static'
      }
    end
  end

  def self.convert_instance_actions(instance, _self)
    instance.actions.collect do |action|
      action = :delete if action == :destroy  # In CIMI destroy operation become delete
      action = :restart if action == :reboot  # In CIMI reboot operation become restart
      { :href => _self.send(:"#{action}_machine_url", instance.id), :rel => "http://www.dmtf.org/cimi/action/#{action}" }
    end
  end

end
