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

require 'deltacloud/base_driver'

require 'erb'
require 'rexml/document'

path = File.dirname(__FILE__)
$: << path

require 'occi_client'

module Deltacloud
  module Drivers
    module Opennebula

class OpennebulaDriver < Deltacloud::BaseDriver

  ######################################################################
  # Hardware profiles
  ######################################################################

  define_hardware_profile 'small'

  define_hardware_profile 'medium'

  define_hardware_profile 'large'

  ######################################################################
  # Realms
  ######################################################################

  (REALMS = [
	Realm.new( {
		:id=>'Any id',
		:name=>'Any name',
		:limit=>:unlimited,
		:state=>'Any state',
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

	images = []
	imagesxml = occi_client.get_images

	storage = REXML::Document.new(imagesxml)
	storage.root.elements.each do |d|
		id = d.attributes['href'].split("/").last

		diskxml = occi_client.get_image(id)

		images << convert_image(diskxml.to_s(), credentials)
	end
	images
  end


  ######################################################################
  # Instances
  ######################################################################

  define_instance_states do
	start.to( :pending )			.on( :create )

	pending.to( :running )			.automatically

	running.to( :stopped )			.on( :stop )

	stopped.to( :running )			.on( :start )
	stopped.to( :finish )			.on( :destroy )
  end


  def instances(credentials, opts=nil)
	occi_client = new_client(credentials)

	instances = []
	instancesxml = occi_client.get_vms

	computes = REXML::Document.new(instancesxml)
	computes.root.elements.each do |d|
		vm_id = d.attributes['href'].split("/").last

		computexml = occi_client.get_vm(vm_id)

		instances << convert_instance(computexml.to_s(), credentials)
	end
        instances = filter_on( instances, :id, opts )
        instances = filter_on( instances, :state, opts )
	instances
  end


  def create_instance(credentials, image_id, opts=nil)
	occi_client = new_client(credentials)

	hwp_id = opts[:hwp_id] || 'small'

	instancexml = ERB.new(OCCI_VM).result(binding)
	instancefile = "|echo '#{instancexml}'"

	xmlvm = occi_client.post_vms(instancefile)

	convert_instance(xmlvm.to_s(), credentials)
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



  private

  def new_client(credentials)
	OCCIClient::Client.new(nil,	credentials.user, credentials.password, false)
  end


  def convert_image(diskxml, credentials)
	disk = REXML::Document.new(diskxml)
	diskhash = disk.root.elements

	Image.new( {
		:id=>diskhash['ID'].text,
		:name=>diskhash['NAME'].text,
		:description=>diskhash['NAME'].text,
		:owner_id=>credentials.user,
		:architecture=>'Any architecture',
	} )
  end


  def convert_instance(computexml, credentials)
	compute = REXML::Document.new(computexml)
	computehash = compute.root.elements

	imageid = computehash['STORAGE/DISK[@type="disk"]'].attributes['href'].split("/").last

	state = (computehash['STATE'].text == "ACTIVE") ? "RUNNING" : "STOPPED"

	hwp_name = computehash['INSTANCE_TYPE'] || 'small'

	networks = []
	(computehash['NETWORK'].each do |n|
		networks << n.attributes['ip']
	end) unless computehash['NETWORK'].nil?

	Instance.new( {
		:id=>computehash['ID'].text,
		:owner_id=>credentials.user,
		:name=>computehash['NAME'].text,
		:image_id=>imageid,
		:instance_profile=>InstanceProfile.new(hwp_name),
		:realm_id=>'Any realm',
		:state=>state,
		:public_addreses=>networks,
		:private_addreses=>networks,
		:actions=> instance_actions_for( state )
	} )
  end


  def occi_action(credentials, id, strstate)
	occi_client = new_client(credentials)

	actionxml = ERB.new(OCCI_ACTION).result(binding)
	actionfile = "|echo '#{actionxml}'"

	xmlvm = occi_client.put_vm(actionfile)

	convert_instance(xmlvm.to_s(), credentials)
  end


  (OCCI_VM = %q{
	<COMPUTE>
		<NAME><%=opts[:name]%></NAME>
		<INSTANCE_TYPE><%= hwp_id %></INSTANCE_TYPE>
		<STORAGE>
			<DISK image="<%= image_id %>" dev="sda1" />
		</STORAGE>
	</COMPUTE>
  }.gsub(/^        /, '') ) unless defined?( OCCI_VM )


  (OCCI_ACTION = %q{
	<COMPUTE>
		<ID><%= id %></ID>
		<STATE><%= strstate %></STATE>
	</COMPUTE>
  }.gsub(/^        /, '') ) unless defined?( OCCI_ACTION )

 end

    end
  end
end
