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
# This driver uses the fog library (Geemus - Wesley Beary) to talk to terremark... see
#                                   http://github.com/geemus/fog
# see terremark vcloud express api at:
# https://community.vcloudexpress.terremark.com/en-us/product_docs/w/wiki/d-complete-vcloud-express-api-document.aspx
#
# 02 May 2010
#
require 'deltacloud/base_driver'
require 'fog'
require 'excon'
require 'nokogiri'

module Deltacloud
  module Drivers
    module Terremark

class TerremarkDriver < Deltacloud::BaseDriver
  feature :instances, :user_name do
    { :max_length => 50 }
  end

  USER_NAME_MAX = constraints(:collection => :instances, :feature => :user_name)[:max_length]

#--
# Vapp State Map... for use with convert_instance (get an integer back from terremark)
#--
VAPP_STATE_MAP = { "0" =>  "PENDING", "1" =>  "PENDING", "2" =>  "STOPPED", "4" =>  "RUNNING" }

#--
# HARDWARE PROFILES
#--
  define_hardware_profile 'default' do
    cpu   [1,2,4,8]
    memory  [512, 1024, 2048, 4096, 8192]
    storage (1..500).to_a
  end
  #storage_disks [1..15]

#--
# IMAGES
#--
#aka "vapp_templates"
  def images(credentials, opts=nil)
      image_list = []
      terremark_client = new_client(credentials)
      safely do
        vdc_id = terremark_client.default_vdc_id
        catalogItems = terremark_client.get_catalog(vdc_id).body['CatalogItems']
        catalogItems.each{ |catalog_item|
          current_item_id = catalog_item['href'].split('/').last
          current_item = terremark_client.get_catalog_item(current_item_id).body['Entity']
            if(current_item['type'] == 'application/vnd.vmware.vcloud.vAppTemplate+xml')
              image_list << convert_image(current_item, credentials.user)
            end
        } #end of catalogItems.each
      end
      image_list = filter_on( image_list, :id, opts )
      image_list = filter_on( image_list, :architecture, opts )
      image_list = filter_on( image_list, :owner_id, opts )
      image_list
  end

#--
# REALMS
#--
#only one realm... everything in US?
  def realms(credentials, opts=nil)
     [Realm.new( {
      :id=>"US-Miami",
      :name=>"United States - Miami",
      :state=> "AVAILABLE"
    } )]
  end

#--
# INSTANCES
#--
#aka vApps
  def instances(credentials, opts=nil)
      instances = []
      terremark_client = new_client(credentials)
      safely do
        vdc_items = terremark_client.get_vdc(terremark_client.default_vdc_id()).body['ResourceEntities']
        vdc_items.each{|current_item|
          if(current_item['type'] == 'application/vnd.vmware.vcloud.vApp+xml')
             vapp_id =  current_item['href'].split('/').last
             vapp = terremark_client.get_vapp(vapp_id)
             instances  << convert_instance(vapp, terremark_client, credentials.user)
          end
        }#end vdc_items.each
      end
      instances = filter_on( instances, :id, opts )
      instances
  end

#--
# FINITE STATE MACHINE
#--
#by default new instance --> powered_off
  define_instance_states do
    start.to(:pending)            .on( :create )
    pending.to(:stopped)          .automatically
    stopped.to(:running)          .on( :start )
    running.to(:running)          .on( :reboot )
    running.to(:stopping)         .on( :stop )
    stopping.to(:stopped)         .automatically
    stopped.to(:finish)           .on( :destroy )
   end


#--
# CREATE INSTANCE
#--
#launch a vapp template. Needs a name, ram, no. cpus, id of vapp_template
  def create_instance(credentials, image_id, opts)
    new_vapp = nil
    vapp_opts = {} #assemble options to pass to Fog::Terremark::Real.instantiate_vapp_template
    terremark_hwp = hardware_profiles(credentials, {:name => 'default'}).first #sanity check values against default
    name = opts[:name]
    if not name
      name = "inst#{Time.now.to_i}"
    end
    if name.length > USER_NAME_MAX
      raise "Parameter name must be #{USER_NAME_MAX} characters or less"
    end
    unless ( (terremark_hwp.include?(:cpu, opts[:hwp_cpu].to_i)) &&
              (terremark_hwp.include?(:memory, opts[:hwp_memory].to_i)) ) then
        raise Deltacloud::ExceptionHandler::ValidationFailure.new(
          StandardError.new("Error with cpu and/or memory values. you said cpu->#{opts[:hwp_cpu]} and mem->#{opts[:hwp_memory]}")
        )
    end
    vapp_opts['cpus'] = opts[:hwp_cpu]
    vapp_opts['memory'] =  opts[:hwp_memory]
    safely do
      terremark_client = new_client(credentials)
#######
#FIXME#  what happens if there is an issue getting the new vapp id? (eg even though created succesfully)
#######
      vapp_id = terremark_client.instantiate_vapp_template(name, image_id, vapp_opts).body['href'].split('/').last
      new_vapp = terremark_client.get_vapp(vapp_id)
      return convert_instance(new_vapp, terremark_client, credentials.user) #return an Instance object
    end
  end

#--
# REBOOT INSTANCE
#--
  def reboot_instance(credentials, id)
    safely do
      terremark_client =  new_client(credentials)
      return terremark_client.power_reset(id)
    end
  end

#--
# START INSTANCE
#--
def start_instance(credentials, id)
  safely do
    terremark_client =  new_client(credentials)
    return terremark_client.power_on(id)
  end
end

#--
# STOP INSTANCE
#--
def stop_instance(credentials, id)
  safely do
    terremark_client = new_client(credentials)
    return terremark_client.power_shutdown(id)
  end
end

#--
# DESTROY INSTANCE
#--
#shuts down... in terremark need to do a futher delete to get rid of a vapp entirely
def destroy_instance(credentials, id)
  safely do
    terremark_client = new_client(credentials)
    return terremark_client.delete_vapp(id)
  end
end

def valid_credentials?(credentials)
  begin
    new_client(credentials)
  rescue
    return false
  end
  true
end

#--
# PRIVATE METHODS:
#--

 private

#--
# CONVERT IMAGE
#--
#gets a vapp_template from a catalog and makes it a Image
  def convert_image(catalog_vapp_template, account_name)
    name = catalog_vapp_template['name']
    #much fudging ensues
    #arch = name.scan(/(36|24).bit/).first
    #k enuf o'that now!
    arch = "n/a" #Leaving out entirely as we don't get one from terremark (could parse but its a fudge)
    Image.new( {
                  :id => catalog_vapp_template['href'].split('/').last,
                  :name => catalog_vapp_template['name'],
                  :architecture => arch,
                  :owner_id => account_name,
                  :description => catalog_vapp_template['name']
               })
  end

#--
# CONVERT INSTANCE
#--
  def convert_instance(vapp, terremark_client, account_name)
      vapp_private_ip = vapp.body['IpAddress']
      vapp_public_ip = terremark_client.get_public_ips(terremark_client.default_vdc_id).body['PublicIpAddresses'].first['name']#get_public_address(terremark_client, vapp_private_ip)
      vapp_status = vapp.body['status']
      current_state = VAPP_STATE_MAP[vapp_status] #status == 0->BEING_CREATED 2->OFF 4->ON
      profile = InstanceProfile.new("default")
      name = vapp.body['name']
      if current_state != "PENDING" #can only grab this stuff after instance is created
        profile.cpu = vapp.body['VirtualHardware']['cpu']
        profile.memory = vapp.body['VirtualHardware']['ram']
#######
#FIXME# could be more that one disk... but for now capture only first
#######
        disk = ((vapp.body['VirtualHardware']['disks'].first.to_i) / 1024 / 1024).to_s
        profile.storage = disk
#######
#FIXME# this is a hack, shouldn't place this info next to name as some clients may rely on name field... probably will introduce
####### a new field in the API for this (e.g. description/text field... human readable)
      #name = "#{name} - [ #{vapp.body['OperatingSystem']['Description']} ]"
      end
      Instance.new( {
                    :id => vapp.body['href'].split('/').last,
                    :owner_id => "#{account_name}",
                    #:image_id => "n/a", #cant get this... see https://community.vcloudexpress.terremark.com/en-us/discussion_forums/f/60/t/376.aspx
                    :name => name,
                    :realm_id => "US-Miami",
                    :state => current_state,
                    :actions => instance_actions_for(current_state),
                    :public_addresses => [ InstanceAddress.new(vapp_public_ip) ],
                    :private_addresses => [ InstanceAddress.new(vapp_private_ip) ],
                    :instance_profile => profile
                    } )
  end

#--
# NEW CLIENT
#--
#use supplied credentials to make a new client for talking to terremark
  def new_client(credentials)
    #Fog constructor expecting  credentials[:terremark_password] and credentials[:terremark_username]
    terremark_credentials = {:terremark_vcloud_username => "#{credentials.user}", :terremark_vcloud_password => "#{credentials.password}" }
    safely do
      terremark_client = Fog::Terremark::Vcloud.new(terremark_credentials)
      vdc_id = terremark_client.default_vdc_id
    end
    if (vdc_id.nil?)
       raise "AuthFailure"
    end
    terremark_client
  end

  exceptions do
    on /AuthFailure/ do
      status 401
    end
  end

end

    end
  end
end
