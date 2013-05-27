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
#

require_relative './occi_client'

# TBD Nokogiri support
require 'rexml/document'

module Deltacloud
  module Drivers
    module Opennebula

class OpennebulaDriver < Deltacloud::BaseDriver

  define_hardware_profile('default')

  ######################################################################
  # Hardware profiles
  #####################################################################
  def hardware_profiles(credentials, opts=nil)
    occi_client = new_client(credentials)
    xml = occi_client.get_instance_types
    if CloudClient.is_error?(xml)
      # OpenNebula 3.0 support
      @hardware_profiles = ['small','medium','large'].map {|name|
        ::Deltacloud::HardwareProfile.new(name)
      }
    else
      # OpenNebula 3.2 support
      @hardware_profiles = REXML::Document.new(xml).root.elements.map {|d|
        elem = d.elements
        ::Deltacloud::HardwareProfile.new(elem['NAME'].text) {
          cpu          elem['CPU'].text if elem['CPU']
          memory       elem['MEMORY'].text if elem['MEMORY']
          storage      elem['STORAGE'].text  if elem['STORAGE']
          architecture elem['ARCHITECTURE'].text if elem['ARCHITECTURE']
        }
      }
    end

    filter_hardware_profiles(@hardware_profiles, opts)
  end

  ######################################################################
  # Realms
  ######################################################################

  (REALMS = [
  Realm.new( {
    :id=>'ONE',
    :name=>'Opennebula',
    :limit=>:unlimited,
    :state=>'AVAILABLE',
  } ),
  ] ) unless defined?( REALMS )


  def realms(credentials, opts=nil)
    return REALMS if ( opts.nil? )
    results = REALMS
    results = filter_on( results, :id, opts )
    results
  end


  ######################################################################
  # Images
  ######################################################################
  def images(credentials, opts=nil)
    occi_client = new_client(credentials)

    xml = treat_response(occi_client.get_images(true))

    # TBD Add extended info in the pool
    images = REXML::Document.new(xml).root.elements.map do |d|
      convert_image(d, credentials)
    end
  end

  def image(credentials, opts=nil)
    occi_client = new_client(credentials)
    xml = treat_response(occi_client.get_image(opts[:id]))
    convert_image(xml, credentials)
  end

  def destroy_image(credentials, id)
    occi_client = new_client(credentials)
    treat_response(occi_client.delete_image(opts[:id]))
  end

  ######################################################################
  # Instances
  ######################################################################

  feature :instances, :user_name
  # TBD Add Context to the VMs

  OCCI_VM = %q{
    <COMPUTE>
      <% if opts[:name] %>
      <NAME><%=opts[:name]%></NAME>
      <% end %>
      <INSTANCE_TYPE><%= opts[:hwp_id] || 'small' %></INSTANCE_TYPE>
      <DISK>
        <STORAGE href="<%= storage_href %>" />
      </DISK>
    </COMPUTE>
  }

  OCCI_ACTION = %q{
    <COMPUTE>
      <ID><%= id %></ID>
      <STATE><%= strstate %></STATE>
    </COMPUTE>
  }

  VM_STATES = {
    "INIT"      => "START",
    "PENDING"   => "PENDING",
    "HOLD"      => "STOPPED",
    "ACTIVE"    => "RUNNING",
    "STOPPED"   => "STOPPED",
    "SUSPENDED" => "STOPPED",
    "DONE"      => "FINISHED",
    "FAILED"    => "FINISHED"
  }

  define_instance_states do
    start.to(:pending)          .on( :create )
    pending.to(:running)        .automatically
    stopped.to(:running)        .on( :start )
    running.to(:running)        .on( :reboot )
    running.to(:stopping)       .on( :stop )
    stopping.to(:stopped)       .automatically
    running.to(:stopping)       .on( :destroy )
    stopping.to(:finish)        .automatically
  end

  def instances(credentials, opts=nil)
    occi_client = new_client(credentials)

    xml = treat_response(occi_client.get_vms(true))
    # TBD Add extended info in the pool
    instances = REXML::Document.new(xml).root.elements.map do |d|
      convert_instance(d, credentials)
    end

    instances = filter_on( instances, :state, opts )
  end

  def instance(credentials, opts=nil)
    occi_client = new_client(credentials)
    xml = treat_response(occi_client.get_vm(opts[:id]))
    convert_instance(xml, credentials)
  end

  def create_instance(credentials, image_id, opts=nil)
    occi_client = new_client(credentials)

    storage_href = "#{occi_client.endpoint}/storage/#{image_id}"

    instancexml  = ERB.new(OCCI_VM).result(binding)
    instancefile = "|echo '#{instancexml}'"

    # TBD Specify VNET in the template.

    xmlvm = treat_response(occi_client.post_vms(instancefile))

    convert_instance(xmlvm, credentials)
  end

  def start_instance(credentials, id)
    occi_action(credentials, id, 'RESUME')
  end


  def stop_instance(credentials, id)
    occi_action(credentials, id, 'STOPPED')
  end


  def destroy_instance(credentials, id)
    occi_action(credentials, id, 'DONE')
  end

  def reboot_instance(credentials, id)
    begin
      occi_action(credentials, id, 'REBOOT')
    rescue Exception => e
      # TBD Check exception
      # OpenNebula 3.0 support
      raise "Reboot action not supported"
    end
  end

  private

  def new_client(credentials)
    OCCIClient::Client.new(api_provider, credentials.user, credentials.password, false)
  end


  def convert_image(diskxml, credentials)
    storage = REXML::Document.new(diskxml.to_s).root.elements

    # TBD Add Image STATE, OWNER
    Image.new( {
      :id=>storage['ID'].text,
      :name=>storage['NAME'].text,
      :description=>storage['TYPE'].text,
      :owner_id=>credentials.user,
      :state=>"AVAILABLE",
      :architecture=>storage['ARCH'],
      :hardware_profiles=>hardware_profiles(credentials)
    } )
  end

  def convert_instance(computexml, credentials)
    computehash = REXML::Document.new(computexml.to_s).root.elements

    network = []
    computehash.each('NIC/IP') {|ip| network<<InstanceAddress.new(ip.text, :type => :ipv4)}

    image_id = nil
    if computehash['DISK/STORAGE']
      image_id = computehash['DISK/STORAGE'].attributes['href'].split("/").last
    end
    if computehash['INSTANCE_TYPE']
      instance_profile = computehash['INSTANCE_TYPE'].text
    else
      instance_profile = 'small'
    end
    Instance.new( {
      :id=>computehash['ID'].text,
      :owner_id=>credentials.user,
      :name=>computehash['NAME'].text,
      :image_id=>image_id,
      :instance_profile=>InstanceProfile.new(instance_profile),
      :realm_id=>'ONE',
      :state=>VM_STATES[computehash['STATE'].text],
      :public_addresses=>network,
      :private_addresses=>[],
      :actions=> instance_actions_for( VM_STATES[computehash['STATE'].text] )
    } )
  end


  def occi_action(credentials, id, strstate)
    occi_client = new_client(credentials)

    actionxml = ERB.new(OCCI_ACTION).result(binding)
    actionfile = "|echo '#{actionxml}'"

    xmlvm = treat_response(occi_client.put_vm(actionfile))

    convert_instance(xmlvm, credentials)
  end


  def treat_response(res)
    safely do
      if CloudClient.is_error?(res)
        raise case res.code
              when "401" then "AuthenticationFailure"
              when "404" then "ObjectNotFound"
              else res.message
              end
      end
    end
    res
  end

  exceptions do
    on /AuthenticationFailure/ do
      status 401
    end

    on /ObjectNotFound/ do
      status 404
    end

    on // do
      status 502
    end
  end
end

    end
  end
end
