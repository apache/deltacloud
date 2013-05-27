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

class CIMI::Service::Machine < CIMI::Service::Base

  metadata :realm,
    :constraints => lambda { |c|
      c.driver.realms(c.credentials).map { |r| r.id }
  }

  metadata :machine_image, :type => 'URI'

  def self.find(id, context)
    instances = []
    if id == :all
      instances = context.driver.instances(context.credentials)
      instances.map { |instance| from_instance(instance, context) }.compact
    else
      instance = context.driver.instance(context.credentials, :id => id)
      raise CIMI::Model::NotFound unless instance
      from_instance(instance, context)
    end
  end

  def perform(action, &block)
    begin
      op = action.operation
      op = :reboot if op == :restart
      if context.driver.send(:"#{op}_instance", context.credentials, ref_id(id))
        block.callback :success
      else
        raise "Operation #{op} failed to execute on given Machine #{ref_id(id)}"
      end
    rescue => e
      raise
      block.callback :failure, e.message
    end
  end

  def self.delete!(id, context)
    context.driver.destroy_instance(context.credentials, id)
    new(context, :values => { :id => id }).destroy
  end

  #returns the newly attach machine_volume
  def self.attach_volume(volume, location, context)
    context.driver.attach_storage_volume(context.credentials,
     {:id=>volume, :instance_id=>context.params[:id], :device=>location})
    CIMI::Service::MachineVolume.find(context.params[:id], context, volume)
  end

  #returns the machine_volume_collection for the given machine
  def self.detach_volume(volume, location, context)
    context.driver.detach_storage_volume(context.credentials,
     {:id=>volume, :instance_id=>context.params[:id], :device=>location})
    CIMI::Service::MachineVolume.collection_for_instance(context.params[:id], context)
  end

  def self.from_instance(instance, context)
    cpu =  memory = (instance.instance_profile.id == "opaque")? "n/a" : nil
    machine_conf = CIMI::Service::MachineConfiguration.find(instance.instance_profile.name, context)
    machine_spec = {
      :name => instance.name,
      :created => instance.launch_time.nil? ? Time.now.xmlschema : Time.parse(instance.launch_time.to_s).xmlschema,
      :description => "No description set for Machine #{instance.name}",
      :id => context.machine_url(instance.id),
      :state => convert_instance_state(instance.state),
      :cpu => cpu || convert_instance_cpu(instance.instance_profile, context),
      :memory => memory || convert_instance_memory(instance.instance_profile, context),
      :disks => { :href => context.machine_url(instance.id)+"/disks"},
      :volumes => { :href=>context.machine_url(instance.id)+"/volumes"},
      :operations => convert_instance_actions(instance, context)
    }
    if context.expand? :disks
      machine_spec[:disks] = CIMI::Service::Disk.find(instance, machine_conf, context, :all)
    end
    if context.expand? :volumes
      machine_spec[:volumes] = CIMI::Service::MachineVolume.find(instance.id, context, :all)
    end
    machine_spec[:realm] = instance.realm_id if instance.realm_id
    machine_spec[:machine_image] = { :href => context.machine_image_url(instance.image_id) } if instance.image_id
    self.new(context, :values => machine_spec)
  end

  # FIXME: This will convert 'RUNNING' state to 'STARTED'
  # which is defined in CIMI (p65)
  #
  def self.convert_instance_state(state)
    case state
      when "RUNNING" then "STARTED"
      when "PENDING" then "CREATING" #aruba only exception... could be "STARTING" here
      else state
    end
  end

  def self.convert_instance_cpu(profile, context)
    cpu_override = profile.overrides.find { |p, v| p == :cpu }
    if cpu_override.nil?
      CIMI::Service::MachineConfiguration.find(profile.id, context).cpu
    else
      cpu_override[1]
    end
  end

  def self.convert_instance_memory(profile, context)
    machine_conf = CIMI::Service::MachineConfiguration.find(profile.name, context)
    memory_override = profile.overrides.find { |p, v| p == :memory }
    memory_override.nil? ? machine_conf.memory.to_i : context.to_kibibyte(memory_override[1].to_i,"MB")
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

  def self.convert_instance_actions(instance, context)
    actions = instance.actions.collect do |action|
      action = :restart if action == :reboot
      name = action
      name = :delete if action == :destroy # In CIMI destroy operation become delete
      { :href => context.send(:"#{action}_machine_url", instance.id), :rel => "http://schemas.dmtf.org/cimi/1/action/#{name}" }
    end
    actions <<  { :href => context.send(:"machine_images_url"), :rel => "http://schemas.dmtf.org/cimi/1/action/capture" } if instance.can_create_image?
    actions
  end

  def self.convert_storage_volumes(instance, context)
    instance.storage_volumes ||= [] #deal with nilpointers
    instance.storage_volumes.map{|vol| {:href=>context.volume_url(vol.keys.first),
                                       :initial_location=>vol.values.first} }
  end

end
