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

class CIMI::Model::Machine < CIMI::Model::Base

  acts_as_root_entity

  resource_attr :realm, :required => false,
    :constraints => lambda { |c| c.driver.realms(c.credentials).map { |r| r.id } }

  resource_attr :machine_image, :required => false, :type => :href

  text :state
  text :cpu

  text :memory

  collection :disks, :class => CIMI::Model::Disk
  collection :volumes, :class => CIMI::Model::MachineVolume

  array :meters do
    scalar :href
  end

  array :operations do
    scalar :rel, :href
  end

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

  def self.create_from_json(body, context)
    json = JSON.parse(body)
    additional_params={}
    machine_template = json['machineTemplate']
    if !machine_template['href'].nil?
      template = current_db.machine_templates.first(:id => machine_template['href'].split('/').last)
      raise 'Could not find the MachineTemplate' if template.nil?
      hardware_profile_id = template.machine_config.split('/').last
      image_id = template.machine_image.split('/').last
    else
      hardware_profile_id = machine_template['machineConfig']["href"].split('/').last
      image_id = machine_template['machineImage']["href"].split('/').last
      if machine_template.has_key? 'credential'
        additional_params[:keyname] = machine_template['credential']["href"].split('/').last
      end
    end
    if machine_template.has_key? "initialState"
      additional_params[:initial_state] = machine_template["initialState"].strip
    end
    additional_params[:name] = json['name'] if json['name']
    additional_params[:realm_id] = json['realm'] if json['realm']
    instance = context.driver.create_instance(context.credentials, image_id, {
      :hwp_id => hardware_profile_id
    }.merge(additional_params))

    # Store attributes that are not supported by the backend cloud to local
    # database:
    machine = from_instance(instance, context)
    machine.name = json['name'] || machine.name
    machine.description = json['description']
    machine.extract_properties!(json)
    machine.save
    machine
  end

  def self.create_from_xml(body, context)
    xml = XmlSimple.xml_in(body)
    additional_params = {}
    if xml['machineTemplate'][0]['href']
      template = current_db.machine_templates_dataset.first(:id => xml['machineTemplate'][0]['href'].split('/').last)
      hardware_profile_id = template.machine_config.split('/').last
      image_id = template.machine_image.split('/').last
    else
      machine_template = xml['machineTemplate'][0]
      hardware_profile_id = machine_template['machineConfig'].first["href"].split('/').last
      image_id = machine_template['machineImage'].first["href"].split('/').last
      if machine_template.has_key? 'credential'
        additional_params[:keyname] = machine_template['credential'][0]["href"].split('/').last
      end
    end
    if xml["machineTemplate"][0].has_key? "initialState"
      additional_params[:initial_state] = xml["machineTemplate"][0]["initialState"].first.strip
    end
    additional_params[:name] = xml['name'][0] if xml['name']
    additional_params[:realm_id] = xml['realm'][0] if xml['realm']
    instance = context.driver.create_instance(context.credentials, image_id, {
      :hwp_id => hardware_profile_id
    }.merge(additional_params))

    # Store attributes that are not supported by the backend cloud to local
    # database:
    machine = from_instance(instance, context)
    machine.name = xml['name'] || machine.name
    machine.description = xml['description']
    machine.extract_properties!(xml)
    machine.save
    machine
  end

  def perform(action, context, &block)
    begin
      if context.driver.send(:"#{action.name}_instance", context.credentials, self.id.split("/").last)
        block.callback :success
      else
        raise "Operation failed to execute on given Machine"
      end
    rescue => e
      block.callback :failure, e.message
    end
  end

  def self.delete!(id, context)
    context.driver.destroy_instance(context.credentials, id)
    CIMI::Model::Machine.new(:id => id).delete
  end

  #returns the newly attach machine_volume
  def self.attach_volume(volume, location, context)
    context.driver.attach_storage_volume(context.credentials,
     {:id=>volume, :instance_id=>context.params[:id], :device=>location})
    CIMI::Model::MachineVolume.find(context.params[:id], context, volume)
  end

  #returns the machine_volume_collection for the given machine
  def self.detach_volume(volume, location, context)
    context.driver.detach_storage_volume(context.credentials,
     {:id=>volume, :instance_id=>context.params[:id], :device=>location})
    CIMI::Model::MachineVolume.collection_for_instance(context.params[:id], context)
  end

  private
  def self.from_instance(instance, context)
    cpu =  memory = (instance.instance_profile.id == "opaque")? "n/a" : nil
    machine_conf = CIMI::Model::MachineConfiguration.find(instance.instance_profile.name, context)
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
      machine_spec[:disks] = CIMI::Model::Disk.find(instance, machine_conf, context, :all)
    end
    if context.expand? :volumes
      machine_spec[:volumes] = CIMI::Model::MachineVolume.find(instance.id, context, :all)
    end
    machine_spec[:realm] = instance.realm_id if instance.realm_id
    machine_spec[:machine_image] = { :href => context.machine_image_url(instance.image_id) } if instance.image_id
    self.new(machine_spec)
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
      CIMI::Model::MachineConfiguration.find(profile.id, context).cpu
    else
      cpu_override[1]
    end
  end

  def self.convert_instance_memory(profile, context)
    machine_conf = CIMI::Model::MachineConfiguration.find(profile.name, context)
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
                                       :attachment_point=>vol.values.first} }
  end

end
