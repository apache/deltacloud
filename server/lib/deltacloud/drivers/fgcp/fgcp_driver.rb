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
# Author: Dies Koper <diesk@fast.au.fujitsu.com>

require_relative 'fgcp_client'
require 'openssl'
require 'xmlsimple'

module Deltacloud
  module Drivers
    module Fgcp
class FgcpDriver < Deltacloud::BaseDriver

  CERT_DIR = ENV['FGCP_CERT_DIR']

  def supported_collections
    DEFAULT_COLLECTIONS + [ :addresses, :load_balancers, :firewalls ]
  end

  feature :instances, :user_name
  feature :images, :user_name
  feature :images, :user_description


  def valid_credentials?(credentials)
    begin
      client = new_client(credentials)
      # use a relativily cheap operation that is likely to succeed
      # (i.e. not requiring particular access privileges)
      client.list_server_types
    rescue
      return false
    end
    true
  end

  ######################################################################
  # Instance state machine
  #####################################################################
  define_instance_states do
    start.to( :pending )          .on( :create )  # new instances do not start automatically
    pending.to( :stopped )        .automatically  # after creation they are in a stopped state
#    running.to( :running )        .on( :reboot ) # there is no single reboot operation
    running.to( :stopping )       .on( :stop )    # stopping an instance does not automatically destroy it
#    running.to( :finish )        .on( :destroy ) # running instances cannot be destroyed in a single step; they need to be stopped first
    stopping.to( :stopped )       .automatically  # stopping an instance does not automatically destroy it
    stopped.to(:running)          .on( :start )   # obvious
    stopped.to(:finish)           .on( :destroy ) # only destroy removes an instance, and it has to be stopped first
  end

  ######################################################################
  # Hardware profiles
  #####################################################################
  def hardware_profiles(credentials, opts=nil)
    safely do
      client = new_client(credentials)
      xml = client.list_server_types

      @hardware_profiles = []
      if xml['servertypes']
        xml['servertypes'][0]['servertype'].each do |type|

          arch = type['cpu'][0]['cpuArch'][0] # returns 'IA' or 'SPARC'. IA currently offered is x86_64
          cpu = type['cpu'][0]['cpuPerf'][0].to_f * type['cpu'][0]['numOfCpu'][0].to_i

          @hardware_profiles << ::Deltacloud::HardwareProfile.new(type['name'][0]) {
            cpu          cpu.to_f == cpu.to_f.floor ? cpu.to_i : cpu.to_f # omit '.0' if whole number
            memory       (type['memory'][0]['memorySize'][0].to_f * 1024) # converted to MB
            architecture (arch == 'IA') ? 'x86_64' : arch
            #storage <- defined by image, not hardware profile
            #if 'storage' is not added, displays 'storage:0' in GUI
            #storage ''
          }
        end
      end
    end
#TODO: is there a way to sort them by arch and memory?
#current order is as returned by API which is not a natural order
#    @hardware_profiles.sort_by{|e| [e.architecture, e.memory]}
    filter_hardware_profiles(@hardware_profiles, opts)
  end

  ######################################################################
  # Images
  ######################################################################
  def images(credentials, opts={})
    images = []

    safely do
      client = new_client(credentials)
      xml = client.list_disk_images
      hwps = hardware_profiles(credentials)

      # use client to get a list of images from the back-end cloud and then create
      # a Deltacloud Image object for each of these. Filter the result
      # (eg specific image requested) and return to user
      if xml['diskimages'] # not likely to not be so, but just in case
        xml['diskimages'][0]['diskimage'].each do |img|

          images << Image.new(
            :id => img['diskimageId'][0],
            :name => img['diskimageName'][0].to_s,
            :description => img['description'][0].to_s,
            :owner_id => img['registrant'][0].to_s, # or 'creatorName'?
            :state => 'AVAILABLE', #server keeps no particular state. If it's listed, it's available for use.
            # This will determine image architecture using OS name.
            # Usually the OS name includes '64bit' or '32bit'. If not,
            # it will fall back to 64 bit.
            :architecture => img['osName'][0].to_s =~ /.*32.?bit.*/ ? 'i386' : 'x86_64',
            :hardware_profiles => hwps
          ) if opts[:id].nil? or opts[:id] == img['diskimageId'][0]
        end
      end
    end

    images = filter_on( images, :id, opts )
    images = filter_on( images, :architecture, opts )
    images = filter_on( images, :owner_id, opts )
    images.sort_by{|e| [e.owner_id, e.architecture, e.name, e.description]}
  end

  # Create a new image from the given instance, with optionally provided name and description
  def create_image(credentials, opts={})
    safely do
      client = new_client(credentials)

      if opts[:name].nil?
        # default to instance name
        instance = client.get_vserver_attributes(opts[:id])
        opts[:name] ||= instance['vserver'][0]['vserverName']
        opts[:description] ||= opts[:name]
      end

      client.register_private_disk_image(opts[:id], opts[:name], opts[:description])
      hwps = hardware_profiles(credentials)

      #can't retrieve image info until it's completed
      Image.new(
        :id                => "PENDING-#{opts[:name]}", #TODO: add check to create_instance to raise error for this image ID?
        :name              => opts[:name],
        :description       => opts[:description],
        :state             => 'PENDING',
        :hardware_profiles => hwps
      )
    end
  end

  def destroy_image(credentials, image_id)
    safely do
      client = new_client(credentials)
      client.unregister_disk_image(image_id)
    end
  end

  ######################################################################
  # Realms
  ######################################################################
  def realms(credentials, opts={})
    realms = []
    safely do
      client = new_client(credentials)
  # opts may include scope: system, network
  # first retrieve list of VSYS ids (and add if scope is not only filtering for network)
      if opts and opts[:id]

        # determine id belongs to vsys or network
        vsys_id = client.extract_vsys_id(opts[:id])
        vsys = client.get_vsys_attributes(vsys_id)['vsys'][0]
        realm_name = vsys['vsysName'][0]
        limit = '[VSYS]'
        if opts[:id] != vsys_id # network id specified
          opts[:id] =~ /^.*\b(\w+)$/
          realm_name += ' [' + $1 + ']' # vsys name or vsys name + network [DMZ/SECURE1/SECURE2]
          limit = '[Network segment]'
        end
        realms << Realm::new(
                    :id => opts[:id],
                    :name => realm_name,
                    #:limit => :unlimited,
                    :limit => limit,
                    :state => 'AVAILABLE' # map to state of FW/VSYS (reconfiguring = unavailable)?
                   # :scope => 'system'
                  )
      elsif xml = client.list_vsys['vsyss']

        xml[0]['vsys'].each do |vsys|

          realms << Realm::new(
                      :id => vsys['vsysId'][0], # vsysId or networkId
                      :name => vsys['vsysName'][0], # vsys name or vsys name + network (DMZ/SECURE1/SECURE2)
                      #:limit => :unlimited,
                      :limit => '[VSYS]',
                      :state => 'AVAILABLE' # map to state of FW/VSYS (reconfiguring = unavailable)?
                     # :scope => 'system'
                    )
          # then retrieve and add list of network segments
          client.get_vsys_configuration(vsys['vsysId'][0])['vsys'][0]['vnets'][0]['vnet'].each do |vnet|

            vnet['networkId'][0] =~ /^.*\b(\w+)$/
            realm_name = vsys['vsysName'][0].to_s + ' [' + $1 + ']' # vsys name or vsys name + network [DMZ/SECURE1/SECURE2]
            realms << Realm::new(
                        :id => vnet['networkId'][0], # vsysId or networkId
                        :name => realm_name,
                        #:limit => :unlimited,
                        :limit => '[Network segment]',
                        :state => 'AVAILABLE' # map to state of FW/VSYS (reconfiguring = unavailable)?
                      #  :scope => 'network'
                      )
          end
        end
      end
    end
    filter_on(realms, :id, opts)
  end

  ######################################################################
  # Instances
  ######################################################################
  def instances(credentials, opts={})
    instances = []

    safely do
      client = new_client(credentials)

      if opts and opts[:id]
        vsys_id = client.extract_vsys_id(opts[:id])
        vsys_config = client.get_vsys_configuration(vsys_id)
        vsys_config['vsys'][0]['vservers'][0]['vserver'].each do |vserver|
          if vserver['vserverId'][0] == opts[:id]

            # check state first as it may be filtered on
            state_data = instance_state_data(vserver, client)
            if opts[:state].nil? or opts[:state] == state_data[:state]

              instance = convert_to_instance(client, vserver, state_data)
              add_instance_details(instance, client, vserver)

              instances << instance
            end
          end
        end
      elsif xml = client.list_vsys['vsyss']

        xml[0]['vsys'].each do |vsys|

          # use get_vsys_configuration (instead of get_vserver_configuration) to retrieve all vservers in one call
          vsys_config = client.get_vsys_configuration(vsys['vsysId'][0])
          vsys_config['vsys'][0]['vservers'][0]['vserver'].each do |vserver|

            # to keep the response time of this method acceptable, retrieve state
            # only if required because state is filtered on
            state_data = opts[:state] ? instance_state_data(vserver, client) : nil
            # filter on state
            if opts[:state].nil? or opts[:state] == state_data[:state]
              instances << convert_to_instance(client, vserver, state_data)
            end
          end
        end
      end
    end
    instances = filter_on( instances, :state, opts )
    filter_on( instances, :id, opts )
  end

  # Start an instance, given its id.
  def start_instance(credentials, id)
    safely do
      client = new_client(credentials)
      if id =~ /^.*-S-0001/ # FW
        client.start_efm(id)
      else
        # vserver or SLB (no way to tell which from id)
        begin
          client.start_vserver(id)
        rescue Exception => ex
          # if not found, try starting as SLB
          if not ex.message =~ /VALIDATION_ERROR.*/
            raise ex
          else
            begin
              client.start_efm(id)
            rescue
              # if that fails as well, just raise the original error
              raise ex
            end
          end
        end
      end
    end
    instances(credentials, {:id => id}).first
  end

  # Stop an instance, given its id.
  def stop_instance(credentials, id)
    safely do
      client = new_client(credentials)
      if id =~ /^.*-S-0001/ # FW
        client.stop_efm(id)
      else
        # vserver or SLB (no way to tell which from id)
        begin
          client.stop_vserver(id)
        rescue Exception => ex
          #if not found, try stopping as SLB
          if not ex.message =~ /VALIDATION_ERROR.*/
            raise ex
          else
            begin
              client.stop_efm(id)
            rescue
              # if that fails as well, just raise the original error
              raise ex
            end
          end
        end
      end
    end
    instances(credentials, {:id => id}).first
  end

  # FGCP has no API for reboot
#  def reboot_instance(credentials, id)
#    raise 'Reboot action not supported'
#  end

  # Create a new instance, given an image id
  # opts can include an optional name for the instance, hardware profile (hwp_id) and realm_id
  def create_instance(credentials, image_id, opts={})
    name = opts[:name]
    # default to 'economy' or obtain latest hardware profiles and pick the lowest spec profile?
    hwp = opts[:hwp_id] || 'economy'
    network_id = opts[:realm_id]
    safely do
      client = new_client(credentials)
      xml = client.create_vserver(name, hwp, image_id, network_id)
      # returns vserver details
      instances(credentials, {:id => xml['vserverId'][0]}).first
    end
  end

  # Destroy an instance, given its id.
  def destroy_instance(credentials, id)
    safely do
      client = new_client(credentials)
      vsys_id = client.extract_vsys_id(id)
      if id == "#{vsys_id}-S-0001" # if FW
        client.destroy_vsys(vsys_id)
      else
        # vserver or SLB (no way to tell which from id)
        begin
          client.destroy_vserver(id)
        rescue Exception => ex
          # if not found, try destroying as SLB
          if not ex.message =~ /VALIDATION_ERROR.*/
            raise ex
          else
            begin
              client.destroy_efm(id)
            rescue
              # if that fails as well, just raise the original error
              raise ex
            end
          end
        end
      end
    end
  end

  def run_on_instance(credentials, opts={})
    target = instance(credentials, opts)
    safely do
      param = {}
      param[:port] = opts[:port] || '22'
      param[:ip] = target.public_addresses.first.address
      param[:credentials] = { :username => target.username }

      if opts[:private_key] and opts[:private_key].length > 1
        param[:private_key] = opts[:private_key]
      else
        password = (opts[:password] and opts[:password].length > 0) ? opts[:password] : target.password
        param[:credentials].merge!({ :password => password })
      end

      Deltacloud::Runner.execute(opts[:cmd], param)
    end
  end

  ######################################################################
  # Storage volumes
  ######################################################################
  def storage_volumes(credentials, opts={})
    volumes = []
    safely do
      client = new_client(credentials)
      if opts and opts[:id]
        vdisk = client.get_vdisk_attributes(opts[:id])['vdisk'][0]
        state = client.get_vdisk_status(opts[:id])['vdiskStatus'][0]
        actions = []
        if state == 'NORMAL'
          if vdisk['attachedTo'].nil?
            state = 'AVAILABLE'
            actions = [:attach, :destroy]
          else
            state = 'IN-USE'
            actions = [:detach]
          end
        end

        volumes << StorageVolume.new(
          :id          => opts[:id],
          :name        => vdisk['vdiskName'][0],
          :capacity    => vdisk['size'][0],
          :instance_id => vdisk['attachedTo'].nil? ? nil : vdisk['attachedTo'][0],
          :state       => state,
          :actions     => actions,
          # alining with rhevm, which returns 'system' or 'data'
          :kind        => determine_storage_type(opts[:id]),
          :realm_id    => client.extract_vsys_id(opts[:id])
        )
      elsif xml = client.list_vsys['vsyss']

        xml[0]['vsys'].each do |vsys|

          vdisks = client.list_vdisk(vsys['vsysId'][0])['vdisks'][0]

          if vdisks['vdisk']
            vdisks['vdisk'].each do |vdisk|

              #state requires an additional call per volume. Only set if attached.
              #exclude system disks as they are not detachable?
              volumes << StorageVolume.new(
                :id          => vdisk['vdiskId'][0],
                :name        => vdisk['vdiskName'][0],
                :capacity    => vdisk['size'][0],
                :instance_id => vdisk['attachedTo'].nil? ? nil : vdisk['attachedTo'][0],
                :realm_id    => client.extract_vsys_id(vdisk['vdiskId'][0]),
                # alining with rhevm, which returns 'system' or 'data'
                :kind        => determine_storage_type(vdisk['vdiskId'][0]),
                :state       => vdisk['attachedTo'].nil? ? nil : 'IN-USE'
              )
            end
          end
        end
      end
    end
    volumes
  end

  def create_storage_volume(credentials, opts={})
    opts ||= {}
    opts[:name]     ||= Time.now.to_s
    opts[:capacity] ||= '1' # DC default
    #size has to be a multiple of 10: round up.
    opts[:capacity] = ((opts[:capacity].to_f / 10.0).ceil * 10.0).to_s

    safely do
      client = new_client(credentials)

      if opts[:realm_id]
        # just in case the user got confused and specified a network id
        opts[:realm_id] = client.extract_vsys_id(opts[:realm_id])
      elsif xml = client.list_vsys['vsyss']

        # use first vsys returned as realm
        opts[:realm_id] = xml[0]['vsys'][0]['vsysId'][0]
      end

      vdisk_id = client.create_vdisk(opts[:realm_id], opts[:name], opts[:capacity])['vdiskId'][0]

      StorageVolume.new(
        :id          => vdisk_id,
        :created     => Time.now.to_s,
        :name        => opts[:name],
        :capacity    => opts[:capacity],
        :realm_id    => client.extract_vsys_id(opts[:realm_id]),
        :instance_id => nil,
        :state       => 'DEPLOYING',
        # alining with rhevm, which returns 'system' or 'data'
        :kind        => 'data',
        :actions     => []
      )
    end
  end

  def destroy_storage_volume(credentials, opts={})
    safely do
      client = new_client(credentials)
      client.destroy_vdisk(opts[:id])
    end
  end

  def attach_storage_volume(credentials, opts={})
    safely do
      client = new_client(credentials)
      client.attach_vdisk(opts[:instance_id], opts[:id])
    end
    storage_volumes(credentials, opts).first
  end

  def detach_storage_volume(credentials, opts={})
    safely do
      client = new_client(credentials)
      client.detach_vdisk(opts[:instance_id], opts[:id])
    end
    storage_volumes(credentials, opts)
  end

  ######################################################################
  # Storage Snapshots
  ######################################################################
  def storage_snapshots(credentials, opts={})
    snapshots = []

    safely do
      client = new_client(credentials)
      if opts and opts[:id]
        vdisk_id, backup_id = split_snapshot_id(opts[:id])

        if backups = client.list_vdisk_backup(vdisk_id)['backups']

          backups[0]['backup'].each do |backup|

            snapshots << StorageSnapshot.new(
              :id => opts[:id],
              #:state => ?,
              :storage_volume_id => vdisk_id,
              :created => backup['backupTime'][0]
            ) if backup_id = backup['backupId'][0]
          end
        end
      elsif xml = client.list_vsys['vsyss']

        xml[0]['vsys'].each do |vsys|

          vdisks = client.list_vdisk(vsys['vsysId'][0])['vdisks'][0]
          if vdisks['vdisk']
            vdisks['vdisk'].each do |vdisk|

#TODO: skipping system disks for now to improve performance
if vdisk['vdiskId'][0] =~ /^.*-D-\d\d\d\d/

              backups = client.list_vdisk_backup(vdisk['vdiskId'][0])
              if backups['backups'] and backups['backups'][0]['backup']
                backups['backups'][0]['backup'].each do |backup|

                  snapshots << StorageSnapshot.new(
                    :id => generate_snapshot_id(vdisk['vdiskId'][0], backup['backupId'][0]),
                    #:state => ?,
                    :storage_volume_id => vdisk['vdiskId'][0],
                    :created => backup['backupTime'][0]
                  )
                end
              end
end
            end
          end
        end
      end
    end

    snapshots
  end

  def create_storage_snapshot(credentials, opts={})
    safely do
      client = new_client(credentials)
      client.backup_vdisk(opts[:volume_id])
    end

    StorageSnapshot.new(
      :id                 => "PENDING-#{opts[:volume_id]}", # don't know id until backup completed
      :state              => 'PENDING', # OK to make up a state like that?
      :storage_volume_id  => opts[:volume_id],
      :created            => Time.now.to_s
    )
  end

  def destroy_storage_snapshot(credentials, opts={})
    vdisk_id, backup_id = split_snapshot_id(opts[:id])
    safely do
      client = new_client(credentials)
      client.destroy_vdisk_backup(client.extract_vsys_id(opts[:id]), backup_id)
    end
  end

  ######################################################################
  # Addresses
  ######################################################################
  def addresses(credentials, opts={})
    addrs_to_instance = {}
    ips_per_vsys = {}
    safely do
      client = new_client(credentials)
      opts ||= {}
      public_ips = client.list_public_ips(opts[:realm_id])['publicips']
      return [] if public_ips.nil? or public_ips[0]['publicip'].nil?

      # first discover the VSYS each address belongs to
      public_ips[0]['publicip'].each do |ip|
        if not opts[:id] or opts[:id] == ip['address'][0]

          ips_per_vsys[ip['vsysId'][0]] ||= []
          ips_per_vsys[ip['vsysId'][0]] << ip['address'][0]
        end
      end

      ips_per_vsys.each_pair do |vsys_id, ips|
        #nat rules show both mapped and unmapped IP addresses
        #may not have privileges to view nat rules on this vsys
        begin
          fw_id = "#{vsys_id}-S-0001"
          nat_rules = client.get_efm_configuration(fw_id, 'FW_NAT_RULE')['efm'][0]['firewall'][0]['nat'][0]['rules'][0]
        rescue RuntimeError => ex
          raise ex unless ex.message =~ /^(ACCESS_NOT_PERMIT).*/
        end

        if nat_rules and nat_rules['rule']
          # collect all associated IP addresses (pub->priv) in vsys
          associated_ips = {}

          nat_rules['rule'].each do |rule|
            if opts[:id].nil? or opts[:id] == rule['publicIp'][0] # filter on public IP if specified
              associated_ips[rule['publicIp'][0]] = rule['privateIp'][0] if rule['privateIp']
            end
          end

          # each associated target private IP belongs to either a vserver or SLB
          # 1. for vservers, obtain all ids from get_vsys_configuration in one call
          vsys = client.get_vsys_configuration(vsys_id)
          vsys['vsys'][0]['vservers'][0]['vserver'].each do |vserver|

            if determine_server_type(vserver) == 'vserver'
              vnic = vserver['vnics'][0]['vnic'][0]

              associated_ips.find do |pub,priv|
                addrs_to_instance[pub] = vserver['vserverId'][0] if priv == vnic['privateIp'][0]
              end if vnic['privateIp'] # when an instance is being created, the private ip is not known yet

            end
          end # of loop over vsys' vservers

          # 2. for slbs, obtain all ids from list_efm
          if addrs_to_instance.keys.size < associated_ips.keys.size # only if associated ips left to process

            if slbs = client.list_efm(vsys_id, 'SLB')['efms']
              slbs[0]['efm'].find do |slb|

                associated_ips.find do |pub,priv|
                  addrs_to_instance[pub] = slb['efmId'][0] if priv == slb['slbVip'][0]
                end
                addrs_to_instance.keys.size < associated_ips.keys.size # stop if no associated ips left to process
              end
            end
          end
        end # of nat_rules has rules
      end # of ips_per_vsys.each
    end

    addresses = []
    ips_per_vsys.values.each do |pubs|
      addresses += pubs.collect do |pub|
        Address.new(:id => pub, :instance_id => addrs_to_instance[pub])
      end
    end
    addresses
  end

  def address(credentials, opts={})
    addresses(credentials, opts).first
  end

  def create_address(credentials, opts={})
    safely do
      client = new_client(credentials)
      opts ||= {}
      if opts[:realm_id]
        # just in case a network realm was passed
        opts[:realm_id] = client.extract_vsys_id(opts[:realm_id])
      else
        # get first vsys
        xml = client.list_vsys
        opts[:realm_id] = xml['vsyss'][0]['vsys'][0]['vsysId'][0] if xml['vsyss']
      end

      client.allocate_public_ip(opts[:realm_id])
    end
    #TODO: new address not returned immediately!
    Address.new(:id => 'PENDING-xxx.xxx.xxx.xxx')
  end

  def destroy_address(credentials, opts={})
    opts ||= {}
    safely do
      client = new_client(credentials)
      if opts[:realm_id]
        opts[:realm_id] = client.extract_vsys_id(opts[:realm_id])
      else
        xml = client.list_public_ips
        if xml['publicips']
          xml['publicips'][0]['publicip'].find do |ip|
            opts[:realm_id] = ip['vsysId'][0] if opts[:id] == ip['address'][0]
          end
        end
      end
      begin
        # detach just in case
        client.detach_public_ip(opts[:realm_id], opts[:id])
      rescue Exception => ex
        raise ex unless ex.message =~ /^ALREADY_DETACHED.*/
      end
      client.free_public_ip(opts[:realm_id], opts[:id])
    end
  end

  def associate_address(credentials, opts={})
    safely do
      client = new_client(credentials)
      vsys_id = client.extract_vsys_id(opts[:instance_id])

      begin
        client.attach_public_ip(vsys_id, opts[:id])
      rescue Exception => ex
        raise ex unless ex.message =~ /^ALREADY_ATTACHED.*/
      end

      # retrieve private address
      # use get_vsys_configuration (instead of get_vserver_configuration) to also know if instance is an SLB
      vsys_config = client.get_vsys_configuration(vsys_id)
      vserver = vsys_config['vsys'][0]['vservers'][0]['vserver'].find { |e| e['vserverId'][0] == opts[:instance_id] }

      case determine_server_type(vserver)
      when 'vserver'
        private_ip = vserver['vnics'][0]['vnic'][0]['privateIp'][0]
      when 'SLB'
        if slbs = client.list_efm(vsys_id, 'SLB')['efms']
          private_ip = slbs[0]['efm'].find { |slb| slb['slbVip'][0] if slb['efmId'][0] == opts[:instance_id] }
        end
      end if vserver

      fw_id = "#{vsys_id}-S-0001"
      nat_rules = client.get_efm_configuration(fw_id, 'FW_NAT_RULE')['efm'][0]['firewall'][0]['nat'][0]['rules'][0]

      if nat_rules and not nat_rules.empty? # happens only if no enabled IP address?

        nat_rules['rule'].each do |rule|

          if rule['publicIp'][0] == opts[:id]
            rule['privateIp'] = [ private_ip ]
            rule['snapt'] = [ 'true' ]
          else
            rule['snapt'] = [ 'false' ]
          end
        end
      end

      new_rules = {
        'configuration' => [
          'firewall_nat'  => [nat_rules]
      ]}

      # create FW configuration xml file with new rules
      conf_xml_new = XmlSimple.xml_out(new_rules,
        'RootName' => 'Request'
      )
      client.update_efm_configuration(fw_id, 'FW_NAT_RULE', conf_xml_new)

      Address.new(:id => opts[:id], :instance_id => opts[:instance_id])
    end
  end

  def disassociate_address(credentials, opts={})
    safely do
      client = new_client(credentials)

      if not opts[:realm_id]

        if public_ips = client.list_public_ips['publicips']

          public_ips[0]['publicip'].find do |ip|
            opts[:realm_id] = ip['vsysId'][0] if opts[:id] == ip['address'][0]
          end
        end
      end

      vsys_id = client.extract_vsys_id(opts[:realm_id])
      fw_id = "#{vsys_id}-S-0001"
      nat_rules = client.get_efm_configuration(fw_id, 'FW_NAT_RULE')['efm'][0]['firewall'][0]['nat'][0]['rules'][0]

      if nat_rules and not nat_rules.empty? # happens only if no enabled IP address?

        nat_rules['rule'].reject! { |rule| rule['publicIp'][0] == opts[:id] }
      end

      new_rules = {
        'configuration' => [
          'firewall_nat'  => [nat_rules]
      ]}

      # create FW configuration xml file with new rules
      conf_xml_new = XmlSimple.xml_out(new_rules,
        'RootName' => 'Request'
      )

      client.update_efm_configuration(fw_id, 'FW_NAT_RULE', conf_xml_new)
      client.detach_public_ip(client.extract_vsys_id(opts[:realm_id]), opts[:id])
    end
  end

  ######################################################################
  # Firewalls
  ######################################################################
  def firewalls(credentials, opts={})
    firewalls = []
    fw_name = 'Firewall' # currently always 'Firewall'

    safely do
      client = new_client(credentials)
      if opts and opts[:id]
        # get details incl. rules on single FW
        rules = []

        configuration_xml = <<-"eofwpxml"
<?xml version="1.0" encoding ="UTF-8"?>
<Request>
  <configuration>
    <firewall_policy>
    </firewall_policy>
  </configuration>
</Request>
eofwpxml

        fw = client.get_efm_configuration(opts[:id], 'FW_POLICY', configuration_xml)
        fw_name = fw['efm'][0]['efmName'][0] # currently always 'Firewall'
        fw_owner_id = fw['efm'][0]['creator'][0]

        fw['efm'][0]['firewall'][0]['directions'][0]['direction'].each do |direction|

          direction['policies'][0]['policy'].each do |policy|

            sources = []
            ['src', 'dst'].each do |e|

              if policy[e] and policy[e][0] and not policy[e][0].empty?

                ip_address_type = policy["#{e}Type"][0]
                address = policy[e][0]
                address.sub!('any', '0.0.0.0/0') if ip_address_type == 'IP'
                address += '/32' if ip_address_type == 'IP' and not address =~ /.*\/.*/

                sources << {
                  :type    => 'address',
                  :family  => 'ipv4',
                  :address => address.split('/').first,
                  :prefix  => ip_address_type == 'IP' ? address.split('/').last : nil
                }
              end
            end

            # defining ingress as access going from Internet/Intranet -> DMZ -> SECURE1 -> SECURE2
            ingress = policy['id'][0] =~ /[13].*/ ? 'ingress' : 'egress'

            rules << FirewallRule.new({
              :id             => policy['id'][0],
              :allow_protocol => policy['protocol'][0],
              :port_from      => policy['srcPort'] ? policy['srcPort'][0] : nil, # not set for e.g. ICMP
              :port_to        => policy['dstPort'] ? policy['dstPort'][0] : nil, # not set for e.g. ICMP
              :direction      => ingress,
              :sources        => sources
              }) unless policy['id'][0] == '50000' # exclude special case
          end
        end

        firewalls << Firewall.new({
          :id       => opts[:id],
          :name     => fw_name,
  #        :description => '', # get_efm_configuration 'FW_POLICY' does not return description
          :owner_id => fw_owner_id,
          :rules    => rules
        })
      else
        xml = client.list_vsys
        return [] if xml['vsyss'].nil?

        firewalls = xml['vsyss'][0]['vsys'].collect do |vsys|

          Firewall.new({
            :id => vsys['vsysId'][0] + '-S-0001',
            :name => fw_name,
            :description => vsys['baseDescriptor'][0], # should I use vsys' 'description' instead and introduce something else for baseDescriptor?
            :owner_id => vsys['creator'][0]
          })
        end
      end
    end

    firewalls
  end

  def create_firewall(credentials, opts={})
    safely do
      client = new_client(credentials)
      # using 'description' as vsysDescriptor
      vsys_id = client.create_vsys(opts['description'], opts['name'])['vsysId'][0]
      fw_id = vsys_id + '-S-0001'
      Firewall.new({
        :id           => fw_id,
        :name         => opts['name'],
        :description  => opts['description'],
        :owner_id     => '',
        :rules        => []
      })
    end
  end

  def delete_firewall(credentials, opts={})
    safely do
      client = new_client(credentials)
      client.destroy_vsys(client.extract_vsys_id(opts[:id]))
    end
  end

#TODO
#  def create_firewall_rule(credentials, opts={})
#    p opts
#  end

  def delete_firewall_rule(credentials, opts={})
    # retrieve current FW rules, delete rule, send back to API server
    safely do
      client = new_client(credentials)
      conf_xml_old = <<-"eofwopxml"
<?xml version="1.0" encoding ="UTF-8"?>
<Request>
  <configuration>
    <firewall_policy>
    </firewall_policy>
  </configuration>
</Request>
eofwopxml

      # retrieve current rules
      fw = client.get_efm_configuration(opts[:firewall], 'FW_POLICY', conf_xml_old)
      rule50000_log = 'On'

      # delete specified rule and special rule 50000 (handled later)
      fw['efm'][0]['firewall'][0]['directions'][0]['direction'].reject! do |direction|

        direction['policies'][0]['policy'].reject! do |policy|

          rule_id = policy['id'][0]
          # need to use (final) 3 digit id
          policy['id'][0] = rule_id[2..4]
          # storage rule 50000's log attribute for later
          rule50000_log = policy['log'][0] if rule_id == '50000'
          # some elements not allowed if service is NTP, DNS, etc.
          if not policy['dstService'][0] == 'NONE'
            policy.delete('dstType')
            policy.delete('dstPort')
            policy.delete('protocol')
          end
          rule_id == opts[:rule_id] or rule_id == '50000'
        end

        direction['policies'][0]['policy'].empty?
      end

      # add entry for 50000 special rule
      fw['efm'][0]['firewall'][0]['directions'][0]['direction'] << {
        'policies' => [
          'policy' => [
            'log' => [ rule50000_log ]
          ]
        ]
      }

      new_rules = {
        'configuration'   => [
          'firewall_policy' => [
            'directions'      => fw['efm'][0]['firewall'][0]['directions']
        ]
      ]}

      # create FW configuration xml file with new rules
      conf_xml_new = XmlSimple.xml_out(new_rules,
        'RootName' => 'Request'
        )
      conf_xml_new.gsub!(/(<(to|from)>).+(INTERNET|INTRANET)/, '\1\3')

      client.update_efm_configuration(opts[:firewall], 'FW_POLICY', conf_xml_new)
    end
  end

  ######################################################################
  # Load Balancers
  ######################################################################
  def load_balancers(credentials, opts={})
    balancers = []
    safely do
      client = new_client(credentials)
      xml = client.list_vsys
      return [] if xml['vsyss'].nil?

      xml['vsyss'][0]['vsys'].each do |vsys|

        # use get_vsys_configuration (instead of list_efm) to retrieve all SLBs incl. realms in one call
        vsys_config = client.get_vsys_configuration(vsys['vsysId'][0])
        vsys_config['vsys'][0]['vservers'][0]['vserver'].each do |vserver|

          if determine_server_type(vserver) == 'SLB'
            vserver['vnics'][0]['vnic'][0]['networkId'][0] =~ /^.*\b(\w+)$/
            realm_name = vsys['vsysId'][0] + ' [' + $1 + ']' # vsys name + network [DMZ/SECURE1/SECURE2]
            realm = Realm::new(
              :id => vserver['vnics'][0]['vnic'][0]['networkId'][0],
              :name => realm_name,
              :limit => '[Network segment]',
              :state => 'AVAILABLE' # map to state of FW/VSYS (reconfiguring = unavailable)?
            )
            balancer = LoadBalancer.new({
              :id               => vserver['vserverId'][0],
              :realms           => [realm],
              :listeners        => [],
              :instances        => [],
              :public_addresses => []
            })
            balancers << balancer
          end
        end
      end
    end
    balancers
  end

  def load_balancer(credentials, opts={})
    balancer = nil
    safely do
      client = new_client(credentials)

      # use get_vsys_configuration (instead of list_efm) to retrieve all SLBs incl. realms in one call?
      vsys_id = client.extract_vsys_id(opts[:id])
      vsys_config = client.get_vsys_configuration(vsys_id)

      vsys_config['vsys'][0]['vservers'][0]['vserver'].each do |vserver|

        if vserver['vserverId'][0] == opts[:id]
          vserver['vnics'][0]['vnic'][0]['networkId'][0] =~ /^.*\b(\w+)$/
          realm_name = vsys_id + ' [' + $1 + ']' # vsys name + network [DMZ/SECURE1/SECURE2]
          realm = Realm::new(
            :id => vserver['vnics'][0]['vnic'][0]['networkId'][0],
            :name => realm_name,
            :limit => '[Network segment]',
            :state => 'AVAILABLE' # map to state of FW/VSYS (reconfiguring = unavailable)?
          )
          balancer = LoadBalancer.new({
            :id               => vserver['vserverId'][0],
            :realms           => [realm],
            :listeners        => [],
            :instances        => [],
            :public_addresses => []
          })
          begin
            slb_rule = client.get_efm_configuration(opts[:id], 'SLB_RULE')
            slb_rule['efm'][0]['loadbalancer'][0]['groups'][0]['group'][0]['targets'][0]['target'].each do |server|

              balancer.instances << Instance::new(
                :id                => server['serverId'][0],
                :name              => server['serverName'][0],
                :realm_id          => realm,
                :private_addresses => [InstanceAddress.new(server['ipAddress'][0])]
              )

              balancer.add_listener({
                :protocol           => slb_rule['efm'][0]['loadbalancer'][0]['groups'][0]['group'][0]['protocol'][0],
                :load_balancer_port => slb_rule['efm'][0]['loadbalancer'][0]['groups'][0]['group'][0]['port1'][0],
                :instance_port      => server['port1'][0]
              })
            end

            slb_vip = slb_rule['efm'][0]['slbVip'][0]
            opts[:id] =~ /^(.*-S-)\d\d\d\d/
            fw_id = $1 + '0001'
            nat_rules = client.get_efm_configuration(fw_id, 'FW_NAT_RULE')['efm'][0]['firewall'][0]['nat'][0]['rules'][0]
            if nat_rules and not nat_rules.empty?
              nat_rules['rule'].each do |rule|
                balancer.public_addresses << InstanceAddress.new(rule['publicIp'][0]) if rule['privateIp'] and rule['privateIp'][0] == slb_vip
              end
            end
          rescue Exception => ex
            raise ex unless ex.message =~ /(ACCESS_NOT_PERMIT|ILLEGAL_STATE).*/
          end
        end
      end
    end
    balancer
  end

  def create_load_balancer(credentials, opts={})
    safely do
      client = new_client(credentials)
      # if opts['realm_id'].nil? network id specified, pick first vsys' DMZ?
      # CreateEFM -vsysId vsysId -efmType SLB -efmName opts['name'] -networkId opts['realm_id']
      network_id = opts[:realm_id]
      efm = client.create_efm('SLB', opts[:name], network_id)
#        [{:load_balancer_port => opts['listener_balancer_port'],
#          :instance_port => opts['listener_instance_port'],
#          :protocol => opts['listener_protocol']}]
#      )
      load_balancer(credentials, {:id => efm['efmId'][0]})
    end
  end

  def destroy_load_balancer(credentials, id)
    safely do
      client = new_client(credentials)
      client.destroy_efm(id)
    end
  end

  ######################################################################
  # Providers
  ######################################################################
  def providers(credentials, opts={})
    cert, key = convert_credentials(credentials)
    cert.subject.to_s =~ /\b[Cc]=(\w\w)\b/
    country = $1.downcase
    endpoint = Deltacloud::Drivers::driver_config[:fgcp][:entrypoints]['default'][country]
    [
      Provider.new(
        :id => "fgcp-#{country}",
        :name => "Fujitsu Global Cloud Platform - #{country.upcase}",
        :url => endpoint
      )
    ]
  end

# following code enables region drop-down box on GUI. No need as retrieving region from cert (subject c)
#  def configured_providers
#    Deltacloud::Drivers::driver_config[:fgcp][:entrypoints]['default'].keys
#  end

  exceptions do
    on /AuthFailure/ do
      status 401
    end

    # if user doesn't have privileges to view or operate a particular resource
    on /User doesn.t have the right of access./ do
      status 400
    end

    # time out of sync with ntp
    on /VALIDATION_ERROR.*synchronized.*API-Server time/ do
      status 502
    end

    # wrong vserverId, etc.
    on /VALIDATION_ERROR/ do
      status 404
    end

    # wrong vdiskId, etc.
    on /RESOURCE_NOT_FOUND/ do
      status 404
    end

    # destroying a running SLB, etc.
    on /ALREADY_STARTED/ do
      status 502 #?
    end

    # trying to start a running vserver, etc.
    on /ILLEGAL_STATE/ do
      status 502
    end

    # endpoint for country of certificate subject not found
    on /API endpoint not found/ do
      status 502
    end

    on /.*/ do
      status 502 # Provider error
    end
  end

  ######################################################################
  # private
  ######################################################################
  private

  def new_client(credentials)
    cert, key = convert_credentials(credentials)
    FGCPClient.new(cert, key, api_provider)
  end

  def convert_credentials(credentials)
    #username could be 'dkoper'
    #load dkoper/UserCert.p12 from cert dir
    begin
      #p File::join(CERT_DIR, credentials.user, 'UserCert.p12')
      cert_file = File.open(File::join(CERT_DIR, credentials.user, 'UserCert.p12'), 'rb')
    rescue Errno::ENOENT => e # file not found
      raise "AuthFailure: No certificate registered under name \'#{credentials.user}\'"
#      raise Deltacloud::ExceptionHandler::AuthenticationFailure.new(e, "No certificate registered under name #{credentials.user}")
    end
    #TODO: check that cert's cn is indeed the username?
    #cert.subject=/C=AU/O=Fujitsu Limited/CN=diesk_fast
    #raise AuthError(?) if not

    begin
      pkcs12 = OpenSSL::PKCS12.new(cert_file, credentials.password)
    rescue OpenSSL::PKCS12::PKCS12Error => e
      raise "AuthFailure: Could not open the certificate \'#{credentials.user}\'. Wrong password? Is it a valid PKCS12 cert? #{e.message}"
    end

    return pkcs12.certificate, pkcs12.key
  end

  def instance_state_data(vserver, client)
    # determine server is FW/SLB by checking vserver_id (0001 for FW) or nicNo (>0)
    if ['FW', 'SLB'].include? determine_server_type(vserver)
      state = @@INSTANCE_STATE_MAP[client.get_efm_status(vserver['vserverId'][0])['efmStatus'][0]]
      create_image = false
    else
      # vserver
      state = @@INSTANCE_STATE_MAP[client.get_vserver_status(vserver['vserverId'][0])['vserverStatus'][0]]
      create_image = (state == /STOPPED|UNEXPECTED_STOP/)
    end

    {
      :create_image => create_image,
      :actions      => instance_actions_for(state),
      :state        => state
    }
  end

  def add_instance_details(instance, client, vserver)
    # instance details (public IPs, password) currently only apply to vservers (and some to SLBs)
    server = determine_server_type(vserver)
    if not server == 'FW'
      if server == 'vserver'
        # vserver-only details
        images = client.list_disk_images
        images['diskimages'][0]['diskimage'].each do |img|
          if vserver['diskimageId'][0] == img['diskimageId'][0]
            instance.username = img['osName'][0] =~ /Windows.*/ ? 'Administrator' : 'root'
          end
        end
        instance.password = client.get_vserver_initial_password(vserver['vserverId'][0])['initialPassword'][0]
      end

      # retrieve SLB's representative IP address
      if server == 'SLB'
        vsys_id = client.extract_vsys_id(instance.id)
        if slbs = client.list_efm(vsys_id, 'SLB')['efms']
          slbs[0]['efm'].find do |slb|
            instance.private_addresses << InstanceAddress.new(slb['slbVip'][0], :type => :ipv4) if slb['efmId'][0] == instance.id
          end
        end
      end

      # retrieve mapped public ip addresses for vserver or SLB
      #may not have privileges to view nat rules on this vsys
      begin
        vserver['vserverId'][0] =~ /^(.*-S-)\d\d\d\d/
        fw_id = $1 + '0001'
        nat_rules = client.get_efm_configuration(fw_id, 'FW_NAT_RULE')['efm'][0]['firewall'][0]['nat'][0]['rules'][0]
      rescue RuntimeError => ex
        raise ex unless ex.message =~ /ACCESS_NOT_PERMIT.*/
      end

      if nat_rules and not nat_rules.empty?
        private_ips = instance.private_addresses.collect { |e| e.address }
        nat_rules['rule'].each do |rule|
          if rule['privateIp'] and private_ips.include?(rule['privateIp'][0])
            instance.public_addresses << InstanceAddress.new(rule['publicIp'][0], :type => :ipv4)
          end
        end
      end

    end
  end

  def convert_to_instance(client, vserver, state_data=nil)
    state_data ||= {}

    private_ips = []
    vserver['vnics'][0]['vnic'].each do |vnic|
      # when an instance is being created, the private ip is not known yet
      private_ips << InstanceAddress.new(vnic['privateIp'][0], :type => :ipv4) if vnic['privateIp']
    end

    instance_profile = InstanceProfile::new(vserver['vserverType'][0])

    server = determine_server_type(vserver)

    # realm is vsys for FW and network for vserver or SLB
    if server == 'FW'
      realm_id = client.extract_vsys_id(vserver['vserverId'][0])
    else
      realm_id = vserver['vnics'][0]['vnic'][0]['networkId'][0]
    end

    # storage volumes
    storage_volumes = []
    # system volume
    if server == 'vserver'
      storage_volumes << StorageVolume.new(
        :id          => vserver['vserverId'][0],
        :name        => vserver['vserverName'][0],
        #:device => '', # no API to retrieve from
#        :capacity => '10',# or '40', need to check with image (vserver['diskimageId'][0],)
        :realm_id    => realm_id,
        :instance_id => vserver['vserverId'][0],
        :state       => 'IN-USE',
        # alining with rhevm, which returns 'system' or 'data'
        :kind        => 'system',
        :actions     => []
      )
    end
    # additional volumes
    if vserver['vdisks'] and vserver['vdisks'][0]['vdisk']
      vserver['vdisks'][0]['vdisk'].each do |vdisk|

        actions = state_data[:state] and state_data[:state] == 'STOPPED' ? [:detach] : []
        storage_volumes << StorageVolume.new(
          :id          => vdisk['vdiskId'][0],
          :name        => vdisk['vdiskName'][0],
          #:device      => '', # no API to retrieve from
          :capacity    => vdisk['size'][0],
          :realm_id    => client.extract_vsys_id(realm_id),
          :instance_id => vserver['vserverId'][0],
          :state       => 'IN-USE',
          # alining with rhevm, which returns 'system' or 'data'
          :kind        => 'data',
          :actions     => actions
        )
      end
    end

    instance = {
      :id => vserver['vserverId'][0],
      :name => vserver['vserverName'][0],
      :realm_id => realm_id,
      :instance_profile => instance_profile,
      :image_id => vserver['diskimageId'][0],
      :private_addresses => private_ips,
      :storage_volumes => storage_volumes.collect { |v| {v.id => v.device} },
      :firewalls => server != 'FW' ? [client.extract_vsys_id(vserver['vserverId'][0]) + '-S-0001'] : nil,
      :owner_id => vserver['creator'][0]
    }
    instance.merge!( {'create_image' => false}) if not server == 'vserver'
    instance.merge! state_data

    Instance::new(instance)
  end

  def generate_snapshot_id(vdisk_id, backup_id)
    "#{vdisk_id}_#{backup_id}"
  end

  def split_snapshot_id(snapshot_id)
    snapshot_id =~ /^(.*-\d\d\d\d)_(\d\d\d\d)/
    return $1, $2 # vdisk_id, backup_id
  end

  def successful_action?(xml)
    xml['responseStatus'].to_s == 'SUCCESS'
  end

  # determine server is vserver/FW/SLB
  def determine_server_type(vserver)
    # check vserver_id (0001 for FW) or nicNo (>0 for SLB)
    return 'FW'  if vserver['vserverId'][0] =~ /^.*-S-0001/
    return 'SLB' if vserver['vnics'][0]['vnic'][0]['nicNo'][0] != '0'
    return 'vserver'
  end

  # determine storage volume type (system or additional storage)
  def determine_storage_type(id)
    return 'system' if id =~ /^.*-S-\d\d\d\d/
    return 'data'   if id =~ /^.*-D-\d\d\d\d/
    return 'unknown'
  end

  def get_fw_nat_rules_for_vserver(client, vserver)
    /^(\w+-\w+)\b.*/ =~ vserver['vserverId'][0]
    vsys_id = $1

    client.get_efm_configuration("#{vsys_id}-S-0001", 'FW_NAT_RULE')
  end

  # FGCP instance states mapped to DeltaCloud
  @@INSTANCE_STATE_MAP = {
    'DEPLOYING'       =>  'PENDING',
    'RUNNING'         =>  'RUNNING',
    'STOPPING'        =>  'STOPPING',
    'STOPPED'         =>  'STOPPED',
    'STARTING'        =>  'PENDING', # not sure about this one
    'FAILOVER'        =>  'RUNNING',
    'UNEXPECTED_STOP' =>  'STOPPED',
    'RESTORING'       =>  'PENDING',
    'BACKUP_ING'      =>  'PENDING',
    'ERROR'           =>  'STOPPED',
    'START_ERROR'     =>  'STOPPED', # not sure about this one
    'STOP_ERROR'      =>  'STOPPING',
    'REGISTERING'     =>  'PENDING',
    'CHANGE_TYPE'     =>  'PENDING'
  }

end
    end
  end
end
