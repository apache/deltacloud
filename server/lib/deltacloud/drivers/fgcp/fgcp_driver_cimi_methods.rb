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
#Definition of CIMI methods for the Fgcp driver - separation from deltacloud
#API Fgcp driver methods

module Deltacloud::Drivers::Fgcp

  class FgcpDriver < Deltacloud::BaseDriver

    #cimi features
    feature :machines, :default_initial_state do
      { :values => ["STOPPED"] }
    end

    def systems(credentials, opts={})
      safely do
        client = new_client(credentials)
        xml = client.list_vsys['vsyss']
        return [] if xml.nil?
        context = opts[:env]

        systems = xml[0]['vsys'].collect do |vsys|
          vsys_id = vsys['vsysId'][0]
          vsys_description_el = vsys['description']
          CIMI::Model::System.new(
            :id          => vsys_id,
            :name        => vsys['vsysName'][0],
            :description => vsys_description_el ? vsys_description_el[0] : nil,
            :machines    => { :href => context.system_url("#{vsys_id}/machines") },
            :volumes     => { :href => context.system_url("#{vsys_id}/volumes") },
            :networks    => { :href => context.system_url("#{vsys_id}/networks") },
            :addresses   => { :href => context.system_url("#{vsys_id}/addresses") }
          )
        end
        systems = systems.select { |s| opts[:id] == s[:id] } if opts[:id]
        # now add system state
        systems.each do |system|
          vservers = client.list_vservers(system[:id])['vservers'][0]['vserver']
          if vservers.nil?
            system[:state] = client.get_vsys_status(system[:id])['vsysStatus'][0] == 'DEPLOYING' ? 'CREATING' : 'MIXED'
          else
            vservers.each do |vserver|
              state = @@MACHINE_STATE_MAP[client.get_vserver_status(vserver['vserverId'][0])['vserverStatus'][0]]
              system[:state] ||= state
              if system[:state] != state
                system[:state] = 'MIXED'
                break
              end
            end
          end
        end
        systems
      end
    end

    def create_system(credentials, opts={})
      safely do
        client = new_client(credentials)
        name = opts[:name] || "system_#{Time.now.to_s}"
        template = opts[:system_template]
        template_id = template.id || template.href.to_s.gsub(/.*\/([^\/]+)$/, '\1')
        vsys_id = client.create_vsys(template_id, name)['vsysId'][0]
        opts[:id] = vsys_id
        systems(credentials, opts).first
      end
    end

    def destroy_system(credentials, opts={})
      delete_firewall(credentials, {:id=>"#{opts[:id]}-S-0001"})
    end

    def system_machines(credentials, opts={})
      safely do
        client = new_client(credentials)
        #if :expand not specified, list of hrefs only, else convert from :instances?
        context = opts[:env]
        vsys_id = opts[:system_id]
        xml = client.list_vservers(vsys_id)['vservers']
        return [] unless xml and xml[0]['vserver']

        machines = xml[0]['vserver'].collect do |vserver|
          vserver_id = vserver['vserverId'][0]
          CIMI::Model::SystemMachine.new(
            :id      => context.system_url("#{vsys_id}/machines/#{vserver_id}"),
            :name    => vserver['vserverName'][0],
            :machine => { :href => context.machine_url(vserver_id)}
          ) unless opts[:id] and opts[:id] != vserver_id
        end
        machines.compact
      end
    end

    def system_volumes(credentials, opts={})
      safely do
        client = new_client(credentials)
        context = opts[:env]
        vsys_id = opts[:system_id]
        #if :expand not specified, list of hrefs only, else convert from :storage_volumes?
        xml = client.list_vdisk(vsys_id)['vdisks']
        return [] unless xml and xml[0]['vdisk']

        volumes = xml[0]['vdisk'].collect do |vdisk|
          vdisk_id = vdisk['vdiskId'][0]
          CIMI::Model::SystemVolume.new(
            :id      => context.system_url("#{vsys_id}/volumes/#{vdisk_id}"),
            :name    => vdisk['vdiskName'][0],
            :volume  => { :href => context.volume_url(vdisk_id)}
          ) unless opts[:id] and opts[:id] != vdisk_id
        end
        volumes.compact
      end
    end

    def system_networks(credentials, opts={})
      safely do
        client = new_client(credentials)
        context = opts[:env]
        vsys_id = opts[:system_id]
        #if :expand not specified, list of hrefs only, else ??
        vsys = client.get_vsys_configuration(vsys_id)['vsys'][0]

        # retrieve network segment (subnet) info
        networks = vsys['vnets'][0]['vnet'].collect do |vnet|
          network_id = vnet['networkId'][0]
          network_id =~ /.*-(\w)$/
          CIMI::Model::SystemNetwork.new(
            :id      => context.system_url("#{vsys_id}/networks/#{network_id}"),
            :name    => "#{$1} for system #{vsys['vsysName'][0]}",
            :network => { :href => context.network_url(network_id)}
          ) unless opts[:id] and opts[:id] != network_id
        end
        networks.compact
      end
    end

    def system_addresses(credentials, opts={})
      safely do
        client = new_client(credentials)
        context = opts[:env]
        vsys_id = opts[:system_id]
        #if :expand not specified, list of hrefs only, else ??
        xml = client.list_public_ips(vsys_id)['publicips']
        return [] unless xml and xml[0]['publicip']

        # retrieve network segment (subnet) info
        addresses = xml[0]['publicip'].collect do |ip|
          address = ip['address'][0]
          CIMI::Model::SystemAddress.new(
            :id      => context.system_url("#{vsys_id}/addresses/#{address}"),
            :name    => "Public IP address allocated to system #{ip['vsysId'][0]}",
            :address => { :href => context.address_url(address)}
          ) unless opts[:id] and opts[:id] != address
        end
        addresses.compact
      end
    end

    def system_forwarding_groups(credentials, opts={})
      safely do
        client = new_client(credentials)
        context = opts[:env]
        vsys_id = opts[:system_id]
        #if :expand not specified, list of hrefs only, else ??
        vsys = client.get_vsys_configuration(vsys_id)['vsys'][0]

        group_id = "#{vsys_id}-N"
        groups = []
        groups << CIMI::Model::SystemForwardingGroup.new(
          :id               => context.system_url("#{vsys_id}/forwarding_groups/#{group_id}"),
          :name             => "Routing group of system #{vsys['vsysName'][0]}",
          :forwarding_group => { :href => context.forwarding_group_url(group_id)}
        ) unless vsys['vnets'][0]['vnet'].size <= 1 or (opts[:id] and opts[:id] != group_id)
        groups
      end
    end

    def system_templates(credentials, opts={})
      safely do
        client = new_client(credentials)
        context = opts[:env]
        templates = client.list_vsys_descriptor['vsysdescriptors'][0]['vsysdescriptor'].collect do |desc|
          conf = client.get_vsys_descriptor_configuration(desc['vsysdescriptorId'][0])['vsysdescriptor'][0]
          components = conf['vservers'][0]['vserver'].collect do |vserver|
            next if vserver['vserverType'][0] == 'firewall'
            volume_templates = vserver['vdisks'][0]['vdisk'].collect do |vdisk|
              CIMI::Model::VolumeTemplateWithLocation.new(
                :volume_config => CIMI::Model::VolumeConfiguration.new(:capacity => vdisk['size'][0].to_i * 1024 * 1024)
              )
            end if vserver['vdisks']
            {
              :name             => desc['vsysdescriptorName'][0],
              :description      => '',
              :type             => "http://schemas.dmtf.org/cimi/1/Machine",
              :machine_template => CIMI::Model::MachineTemplate.new(
                :name             => vserver['vserverName'][0],
                :description      => '',
                :machine_config   => CIMI::Service::MachineConfiguration.find(vserver['vserverType'][0], context),
                :machine_image    => { :href => context.machine_image_url(vserver['diskimageId'][0]) },
                :volume_templates => volume_templates
              )
            }
          end
          # add network templates
          if conf['vsysdescriptorId'][0] =~ /(1|2|3)-tier Skeleton/
            tiers = ['DMZ', 'Secure1', 'Secure2']
            components += 1.upto($1.to_i).collect do |n|
              {
                :name             => tiers[n],
                :description      => "Network tier #{n}",
                :type             => "http://schemas.dmtf.org/cimi/1/Network",
                :network_template => CIMI::Model::NetworkTemplate.new(
                  :name             => 'Private network',
                  :description      => '',
                  :network_config   => CIMI::Model::NetworkConfiguration.new(
                    :network_type     => 'PRIVATE',
                    :class_of_service => 'BRONZE'
                  )
                )
              }
            end
          end
          CIMI::Model::SystemTemplate.new(
            :id                    => desc['vsysdescriptorId'][0],
            :name                  => desc['vsysdescriptorName'][0],
            :description           => desc['description'][0],
            :component_descriptors => components.compact
          )
        end
        templates = templates.select { |t| opts[:id] == t[:id] } if opts[:id]
        templates
      end
    end

    # FGCP instance states mapped to CIMI machine states
    @@MACHINE_STATE_MAP = {
      'DEPLOYING'       =>  'CREATING',
      'RUNNING'         =>  'STARTED',
      'STOPPING'        =>  'STOPPING',
      'STOPPED'         =>  'STOPPED',
      'STARTING'        =>  'STARTING', # not sure about this one
      'FAILOVER'        =>  'STARTED',
      'UNEXPECTED_STOP' =>  'STOPPED',
      'RESTORING'       =>  'RESTORING',
      'BACKUP_ING'      =>  'CAPTURING',
      'ERROR'           =>  'ERROR',   # allowed actions limited
      'START_ERROR'     =>  'STOPPED', # allowed actions are same as for STOPPED
      'STOP_ERROR'      =>  'STARTED', # allowed actions are same as for RUNNING
      'REGISTERING'     =>  'PENDING',
      'CHANGE_TYPE'     =>  'PENDING'
    }

  end

end
