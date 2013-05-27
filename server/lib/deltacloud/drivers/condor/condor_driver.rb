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

class Instance
  def self.convert_condor_state(state_id)
    case state_id
      when 0,1,5 then 'PENDING'
      when 2     then 'RUNNING'
      when 3,4   then 'SHUTTING_DOWN'
      else raise "Unknown Condor state (#{state_id})"
    end
  end
end

require_relative './condor_client'

module Deltacloud

  module Drivers
    module Condor

      class CondorDriver < Deltacloud::BaseDriver

        feature :instances, :user_data
        feature :instances, :authentication_password

        CONDOR_MAPPER_DIR = ENV['CONDOR_MAPPER_DIR'] || '/var/tmp'

        def hardware_profiles(credentials, opts={})
          results = []
          new_client(credentials) do |condor|
            results = condor.hardware_profiles.collect do |hwp|
              HardwareProfile::new(hwp[:name]) do
                architecture 'x86_64'
                memory  hwp[:memory]
                cpu     hwp[:cpus]
                storage 100
              end
            end
          end
          filter_hardware_profiles(results, opts)
        end

        def realms(credentials, opts={})
          [
            Realm::new(
              :id => 'default',
              :name => 'Default Condor Realm',
              :limit => :unlimited,
              :state => 'AVAILABLE'
            )
          ]
        end

        def images(credentials, opts={})
          results = []
          new_client(credentials) do |condor|
            results = condor.images.collect do |image|
              Image::new(
                :id => Digest::SHA1.hexdigest(image.name).to_s,
                :name => image.name.split(':').first,
                :state => image.state || 'AVAILABLE',
                :architecture => 'x86_64',
                :owner_id => image.owner_id || 'unknown',
                :description => image.description
              )
            end
          end
          filter_on( results, :id, opts )
        end

        def instances(credentials, opts={})
          results = []
          new_client(credentials) do |condor|
            results = condor.instances.collect do |instance|
              vm_uuid = get_value(:uuid, instance.id)
              ip_address = condor.ip_agent.find_ip_by_mac(vm_uuid)
              Instance::new(
                :id => instance.id,
                :name => instance.name,
                :realm_id => 'default',
                :instance_profile => InstanceProfile::new(instance.instance_profile.name),
                :image_id => instance.image_id,
                :public_addresses => [ InstanceAddress.new(ip_address) ],
                :private_addresses => [],
                :owner_id => instance.owner_id,
                :description => instance.name,
                :architecture => 'x86_64',
                :actions => instance_actions_for(instance.state),
                :launch_time => instance.launch_time,
                :username => 'root',
                :password => opts[:password],
                :state => instance.state
              )
            end
          end
          results = filter_on( results, :state, opts )
          filter_on( results, :id, opts )
        end

        def create_instance(credentials, image_id, opts={})
          # User data should contain this Base64 encoded configuration:
          #
          # $config_server_ip:[$uuid]
          #
          # $config_server - IP address of Configuration Server to use (eg. 192.168.1.1)
          # $uuid          - UUID to use for instance (will be used for ConfServer <-> DC
          #                  API communication)
          # $otp           - One-time-password
          #
          user_data = opts[:user_data] ? Base64.decode64(opts[:user_data]) : nil
          if user_data
            config_server_address, vm_uuid, vm_otp = opts[:user_data].strip.split(';')
            if vm_uuid.nil? and vm_otp.nil?
              vm_uuid = config_server_address
              config_server_address = nil
            end
          end
          vm_uuid ||= UUIDTools::UUID.random_create.to_s
          vm_otp ||= vm_uuid[0..7]
          new_client(credentials) do |condor|
            config_server_address ||= condor.ip_agent.address
            image = images(credentials, :id => image_id).first
            hardware_profile = hardware_profiles(credentials, :id => opts[:hwp_id] || 'small').first
            instance = condor.launch_instance(image, hardware_profile, {
              :name => opts[:name] || "i-#{Time.now.to_i}",
              :config_server_address => config_server_address,
              :uuid => vm_uuid,
              :otp => vm_otp,
            }).first
            store(:uuid, vm_uuid, instance.id)
            raise "Error: VM not launched" unless instance
            instance(credentials, { :id => instance.id, :password => vm_otp })
          end
        end

        def destroy_instance(credentials, instance_id)
          old_instance = instance(credentials, :id => instance_id)
          new_client(credentials) do |condor|
            condor.destroy_instance(instance_id)
            remove_key(:uuid, instance_id)
            remove_key(:mac, instance_id)
          end
          old_instance.state = 'PENDING'
          old_instance.actions = instance_actions_for(old_instance.state),
          old_instance
        end

        define_instance_states do
          start.to( :pending )          .automatically
          pending.to( :running )        .automatically
          pending.to( :finish )         .on(:destroy)
          running.to( :running )        .on( :reboot )
          running.to( :stopping )       .on( :destroy )
          pending.to( :finish )         .automatically
        end

        def valid_credentials?(credentials)
          if ( credentials.user != @config[:username] ) or ( credentials.password != @config[:password] )
            return false
          end
          return true
        end

        exceptions do
          on /AuthException/ do
            status 401
          end
          on /ERROR/ do
            status 502
          end
        end

        private

        def new_client(credentials)
          if ( credentials.user != 'condor' ) or ( credentials.password != 'deltacloud' )
            raise Deltacloud::Exceptions::AuthenticationFailure.new
          end
          safely do
            yield CondorCloud::DefaultExecutor.new
          end
        end

        def store(item, key, value)
          FileUtils.mkdir_p(File.join(CONDOR_MAPPER_DIR, item.to_s))
          File.open(File.join(CONDOR_MAPPER_DIR, item.to_s, key), 'w') do |f|
            f.puts(value)
          end
        end

        def get_value(key, id)
          begin
            File.open(File.join(CONDOR_MAPPER_DIR, key.to_s, id)).read.strip
          rescue Errno::ENOENT
            nil
          end
        end

        def remove_key(key, id)
          begin
            FileUtils::rm(File.join(CONDOR_MAPPER_DIR, key.to_s, id))
          rescue
            # We should probably check for specific error conditions here.  Some we will want to log or throw an error for.
            nil
          end
        end
      end
    end
  end
end
