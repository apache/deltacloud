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

require 'restclient'

module Deltacloud
  module Drivers
    module Digitalocean
      class DigitaloceanDriver < Deltacloud::BaseDriver

        feature :instances, :user_name, :authentication_key
        feature :images, :owner_id

        define_instance_states do
          start.to( :pending )          .on( :create )
          pending.to( :running )        .automatically
          running.to( :running )        .on( :reboot )
          running.to( :stopping )       .on( :stop )
          running.to( :finish )         .on( :destroy )
          stopped.to( :running )        .on( :start )
          stopping.to( :stopped )       .automatically
          stopped.to( :finish )         .automatically
          error.from(:running, :pending, :stopping)
        end

        define_hardware_profile('default')

        def hardware_profiles(credentials, opts={})
          do_client = new_client(credentials)
          results = []
          safely do
            if opts[:id]
              size = do_client.get("sizes/#{opts[:id]}")["size"]
              results << hardware_profile_from(size)
            else
              do_client.get("sizes")["sizes"].each do |s|
                size = do_client.get("sizes/#{s['id']}")["size"]
                results << hardware_profile_from(size)
              end
            end
            filter_hardware_profiles(results, opts)
          end
        end

        def hardware_profile_ids(credentials)
          do_client = new_client(credentials)
          hwps = []
          safely do
            do_client.get("sizes")["sizes"].each do |s|
              hwps << HardwareProfile.new(s["id"].to_s)
            end
          end
          hwps
        end

        def realms(credentials, opts={})
          safely do
            realms = new_client(credentials).get('regions')['regions'].map do |r|
              Realm.new(
                :id => r['id'].to_s,
                :name => r['name'],
                :state => 'AVAILABLE',
                :limit => :unlimited
              )
            end
            filter_on(realms, opts, :id)
          end
        end

        # By default images will return list of 'all' images available
        # to launch.
        # With 'owner_id' you can filter them using 'global' and 'my_images'
        # values to get less images.
        #
        def images(credentials, opts={})
          hwps = hardware_profile_ids(credentials)
          unless opts[:id]
            filter = opts[:owner_id] ? { :filter => "my_images" } : {}
            img_arr = safely do
              new_client(credentials).get('images', filter)['images'].map do |i|
                convert_image(hwps, i)
              end
            end
            filter_on( img_arr, :architecture, opts )
          else
            safely do
              [convert_image(
                hwps,
                new_client(credentials).get('images/%s' % opts[:id])['image']
              )]
            end
          end
        end

        # You can only destroy images you own.
        #
        def destroy_image(credentials, image_id)
          safely do
            new_client(credentials).get('images/%s/destroy', image_id)
          end
        end

        def instances(credentials, opts={})
          inst_arr = safely do
            new_client(credentials).get('droplets')['droplets'].map do |i|
              convert_instance(credentials.user, i)
            end
          end
          filter_on inst_arr, :state, opts
        end

        def instance(credentials, opts={})
          safely do
            convert_instance(
              credentials.user,
              new_client(credentials).get("droplets/#{opts[:id]}")["droplet"]
            )
          end
        end

        def create_instance(credentials, image_id, opts={})
          safely do
            client = new_client(credentials)
            args = { :image_id => image_id }
            # Defaults to first realm if realm_id not set
            opts[:realm_id] ||= '1'
            args.merge!(:region_id => opts[:realm_id])
            # Defaults to first size if hwp_id not set
            opts[:hwp_id] ||= '66'
            args.merge!(:size_id => opts[:hwp_id])
            # Default to 'inst-timestamp if name is not set'
            opts[:name] ||= "inst-#{Time.now.to_i}"
            args.merge!(:name => opts[:name])
            args.merge!(:ssh_key_ids => opts[:keyname]) if opts[:keyname]
            convert_instance(
              credentials.user,
              client.get("droplets/new", args)['droplet']
            )
          end
        end

        def destroy_instance(credentials, instance_id)
          safely do
            new_client(credentials).get("droplets/#{instance_id}/destroy/")
          end
        end

        def stop_instance(credentials, instance_id)
          safely do
            new_client(credentials).get("droplets/#{instance_id}/shutdown")
          end
        end

        def start_instance(credentials, instance_id)
          safely do
            new_client(credentials).get("droplets/#{instance_id}/power_on/")
          end
        end

        def reboot_instance(credentials, instance_id)
          safely do
            new_client(credentials).get("droplets/#{instance_id}/reboot/")
          end
        end

        def keys(credentials, opts={})
          client = new_client(credentials)
          safely do
            client.get('ssh_keys')['ssh_keys'].map do |k|
              convert_key(k)
            end
          end
        end

        def key(credentials, opts={})
          client = new_client(credentials)
          safely do
            convert_key(client.get("ssh_keys/#{opts[:id]}")["ssh_key"])
          end
        end

        def destroy_key(credentials, opts={})
          client = new_client(credentials)
          original_key = key(credentials, opts)
          safely do
            client.get("ssh_keys/#{opts[:id]}/destroy")
            original_key.state = 'deleted'
            original_key
          end
        end

        def create_key(credentials, opts={})
          client = new_client(credentials)
          convert_key(
            client.get(
              "ssh_keys/new",
              :name => opts[:key_name],
              :ssh_pub_key => opts[:public_key])['ssh_key']
          )
        end

        exceptions do

          on (/ERROR Unable to verify credentials.*/) do
            status 401
          end

          on(/InternalServerError/) do
            status 502
          end

          on(/No .*Found/) do
            status 404
          end

          on(/An invalid/) do
            status 400
          end

        end

        def valid_credentials?(credentials)
          begin
            hardware_profile_ids(credentials)
          rescue  Deltacloud::Exceptions::AuthenticationFailure
            return false
          rescue => e
            safely { raise e }
          end
          true
        end

        private

        class Client

          API_URL = "https://api.digitalocean.com/"
          attr_reader :credentials

          def initialize(credentials)
            @credentials = credentials
            @resource = RestClient::Resource.new(API_URL)
          end

          def get(uri, opts={})
            opts.merge!(
              :client_id => credentials.user,
              :api_key => credentials.password
            )
            result = @resource[uri].get(:params => opts)
            json_result = JSON::parse(result)
            if json_result['status'] != 'OK'
              p result
              error_message = json_result['error_message'] || "#{json_result['status']} #{json_result['description']}"
              raise error_message
            end
            json_result
          end

        end

        def new_client(credentials)
          Client.new(credentials)
        end

        def extract_arch_from_name(name)
          return 'x86_64' if name.include? 'x64'
          return 'i386' if name.include? 'x32'
        end

        def convert_key(k)
          Key.new(
            :id => k['id'],
            :name => k['name'],
            :credential_type => :key,
            :pem_rsa_key => k['ssh_pub_key'],
            :state => 'available'
          )
        end

        def convert_state(status)
          case status
            when 'active' then 'RUNNING'
            when 'archive', 'new', 'pending' then 'PENDING'
            when 'off'  then 'STOPPED'
            else status.upcase
          end
        end

        def convert_instance(user, i)
          state = convert_state(i['status'] || 'pending')
          address = i['ip_address'].nil? ?
            [] : [InstanceAddress.new(i['ip_address'])]

          Instance.new(
            :id => i['id'].to_s,
            :name => i['name'],
            :image_id => i['image_id'],
            :realm_id => i['region_id'],
            :instance_profile => InstanceProfile.new(i['size_id']),
            :state => state,
            :public_addresses => address,
            :private_addresses => [],
            :owner_id => user,
            :create_image => false,
            :actions => instance_actions_for(state)
          )
        end

        def convert_image(hwps, i)
          Image.new(
            :id => i['id'].to_s,
            :name => i['name'],
            :description => i['distribution'],
            :owner_id => 'global',
            :state => 'AVAILABLE',
            :architecture => extract_arch_from_name(i['name']),
            :hardware_profiles => hwps
          )
        end

        #{"cost_per_hour"=>0.00744, "cpu"=>1, "disk"=>20, "id"=>66, "memory"=>512, "name"=>"512MB"}
        def hardware_profile_from(size)
          hwp = HardwareProfile.new(size["id"].to_s) do
            architecture 'x86_64'
            memory size["memory"]
            storage size["disk"]
            cpu size["cpu"]
          end
          hwp.name=size["name"]
          return hwp
        end

      end
    end
  end
end
