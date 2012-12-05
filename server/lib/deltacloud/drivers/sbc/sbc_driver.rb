#
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

require 'nokogiri'
require_relative './sbc_client'

module Deltacloud
  module Drivers
    module Sbc
#
# Driver for the IBM Smart Business Cloud (SBC).
#
# 31 January 2011
#
class SbcDriver < Deltacloud::BaseDriver
  #
  # Retrieves images
  #
  def images(credentials, opts={})
    sbc_client = new_client(credentials)
    opts ||= {}
    images = []
    images = sbc_client.list_images(opts[:id]).map do |image|
      # Cache image for create_instance; hwp is image-specific. In the
      # current flow of the server, images is always called before a
      # create_instance, making this caching profitable
      @last_image = image
      convert_image(image)
    end
    images = filter_on(images, :architecture, opts)
    images = filter_on(images, :owner_id, opts)
    images
  end

  #
  # Retrieves realms
  #
  def realms(credentials, opts={})
    sbc_client = new_client(credentials)
    doc = sbc_client.list_locations
    realms = doc.xpath('ns2:DescribeLocationsResponse/Location').map { |loc| convert_location(loc) }
    realms = filter_on(realms, :id, opts)
  end

  #
  # Retrieves instances
  #
  def instances(credentials, opts={})
    sbc_client = new_client(credentials)
    opts ||= {}
    instances = []
    instances = sbc_client.list_instances(opts[:id]).map do |instance|
      convert_instance(instance)
    end
  end

  #
  # Creates an instance
  #
  def create_instance(credentials, image_id, opts={})
    sbc_client = new_client(credentials)

    # Copy opts to body; keywords are mapped later
    body = opts.dup
    body.delete('image_id')
    body.delete('hwp_id')
    body.delete('realm_id')

    # Lookup image if nil; tries to avoids extra lookup
    if @last_image.nil? || @last_image['id'] != opts[:image_id]
      @last_image = sbc_client.list_images(image_id).map[0]
    end

    # Map DeltaCloud keywords to SBC
    body['imageID'] = opts[:image_id]
    body['location'] = opts[:realm_id] || @last_image['location']
    if opts[:hwp_id]
      body['instanceType'] = opts[:hwp_id].gsub('-', '/')
    else
      body['instanceType'] = @last_image['supportedInstanceTypes'][0]['id']
    end

    if not body['name']
      body['name'] = Time.now.to_i.to_s
    end

    # Submit instance, parse response
    convert_instance(sbc_client.create_instance(body).map[0])
  end

  #
  # Reboots an instance
  #
  def reboot_instance(credentials, instance_id)
    sbc_client = new_client(credentials)
    sbc_client.reboot_instance(instance_id)
    instance(credentials, instance_id)
  end

  #
  # Stops an instance
  #
  def stop_instance(credentials, instance_id)
    # Stop not supported; rebooting
    reboot_instance(credentials, instance_id)
  end

  #
  # Destroys an instance
  #
  def destroy_instance(credentials, instance_id)
    sbc_client = new_client(credentials)
    sbc_client.delete_instance(instance_id)
    instance(credentials, instance_id)
  end

  exceptions do

    on /AuthFailure/ do
      status 401
    end

    on /BackendError/ do
      status 502
    end

  end

  #
  # --------------------- Private helpers ---------------------
  #
  private

  # SBC instance states mapped to DeltaCloud
  @@INSTANCE_STATE_MAP  = {
    0 => "PENDING",			# New
    1 => "PENDING",			# Provisioning
    2 => "STOPPED",			# Failed
    3 => "STOPPED",			# Removed
    4 => "STOPPED",			# Rejected
    5 => "RUNNING",			# Active
    6 => "STOPPED",			# Unknown
    7 => "PENDING",			# Deprovisioning
    8 => "PENDING",			# Restarting
    9 => "PENDING",			# Starting
    10 => "SHUTTING_DOWN",	# Stopping
    11 => "STOPPED",		# Stopped
    12 => "PENDING",		# Deprovision pending
    13 => "PENDING",		# Restart pending
    14 => "PENDING",		# Attaching
    15 => "PENDING"			# Detaching
  }

  # SBC image states mapped to DeltaCloud
  @@IMAGE_STATE_MAP = {
    0 => "UNAVAILABLE",		# New
    1 => "AVAILABLE",		# Available
    2 => "UNAVAILABLE",		# Unavailable
    3 => "UNAVAILABLE",		# Deleted
    4 => "UNAVAILABLE"		# Capturing
  }

  # SBC location states mapped to DeltaCloud
  @@LOCATION_STATE_MAP = {
    0 => "UNAVAILABLE",		# Unavailable
    1 => "AVAILABLE"		# Available
  }

  #
  # Define state machine for instances
  #
  define_instance_states do
    start.to( :pending )		.automatically
    pending.to( :running )		.automatically
    running.to( :running )		.on( :reboot )
    running.to( :finish )		.on( :destroy )
  end

  #
  # Creates an IBM SBC client
  #
  def new_client(credentials)
    safely do
      return SBCClient.new(credentials.user, credentials.password)
    end
  end

  #
  # Converts JSON to an instance
  #
  def convert_instance(instance)
    state = @@INSTANCE_STATE_MAP[instance["status"]]
    Instance.new(
      :id => instance["id"],
      :owner_id => instance["owner"],
      :image_id => instance["imageId"],
      :name => instance["name"],
      :realm_id => instance["location"],
      :state => state,
      :actions => instance_actions_for(state),
      :public_addresses => [ InstanceAddress.new(instance["primaryIP"]["ip"]) ],
      :private_addresses => [],
      :instance_profile => InstanceProfile.new(instance["instanceType"].gsub('/', '-')),
      :launch_time => instance["launchTime"],
      :keyname => instance["keyName"]
    )
  end

  #
  # Converts JSON to an image
  #
  def convert_image(image)
    Image.new(
      :id => image["id"],
      :name => image["name"],
      :owner_id => image["owner"],
      :description => image["description"],
      :architecture => "i386",	# TODO: parse this from supportedInstanceType IDs w/ HW profile lookup
      :state => @@IMAGE_STATE_MAP[image["state"]]
    )
  end

  #
  # Converts XML to a location
  #
  def convert_location(location)
    Realm.new(
      :id => location.xpath('ID').text,
      :name => location.xpath('Name').text,
      :limit => :unlimited,
      :state => @@LOCATION_STATE_MAP[location.xpath('State').text.to_i]
    )
  end

  #
  # -------------------- Hardware Profiles -----------------
  #
  # TODO: HWP IDs contain '/'; results in invalid URL
  #
  define_hardware_profile('COP32.1-2048-60') do
    cpu				1
    memory			2 * 1024
    storage			60
    architecture	'i386'
  end

  define_hardware_profile('COP64.2-4096-60') do
    cpu				2
    memory			4 * 1024
    storage			60
    architecture	'i386_x64'
  end

  define_hardware_profile('BRZ32.1-2048-60*175') do
    cpu				1
    memory			2 * 1024
    storage			175
    architecture	'i386'
  end

  define_hardware_profile('BRZ64.2-4096-60*500*350') do
    cpu				2
    memory			4 * 1024
    storage			850
    architecture	'i386_x64'
  end

  define_hardware_profile('SLV32.2-4096-60*350') do
    cpu				3
    memory			5 * 1024
    storage			350
    architecture	'i386'
  end

  define_hardware_profile('SLV64.4-8192-60*500*500') do
    cpu				4
    memory			8 * 1024
    storage			1024
    architecture	'i386_x64'
  end

  define_hardware_profile('GLD32.4-4096-60*350') do
    cpu				4
    memory			4 * 1024
    storage			350
    architecture	'i386'
  end

  define_hardware_profile('GLD64.8-16384-60*500*500') do
    cpu				8
    memory			16 * 1024
    storage			1024
    architecture	'i386_x64'
  end

  define_hardware_profile('PLT64.16-16384-60*500*500*500*500') do
    cpu				16
    memory			16 * 1024
    storage			2048
    architecture	'i386_x64'
  end
end
    end
  end
end
