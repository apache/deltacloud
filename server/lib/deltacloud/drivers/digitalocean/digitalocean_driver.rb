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

        feature :instances, :user_name
        feature :images, :owner_id

        define_hardware_profile '66' do
          cpu           1
          memory        512
          storage       20 * 1024
          architecture  ['i386', 'x86_64']
        end

        define_hardware_profile '63' do
          cpu           1
          memory        1024
          storage       30 * 1024
          architecture  ['i386', 'x86_64']
        end

        define_hardware_profile '62' do
          cpu           2
          memory        2 * 1024
          storage       40 * 1024
          architecture  ['i386', 'x86_64']
        end

        define_hardware_profile '64' do
          cpu           2
          memory        4 * 1024
          storage       60 * 1024
          architecture  ['i386', 'x86_64']
        end

        define_hardware_profile '65' do
          cpu           4
          memory        8 * 1024
          storage       80 * 1024
          architecture  ['i386', 'x86_64']
        end

        define_hardware_profile '61' do
          cpu           8
          memory        16 * 1024
          storage       160 * 1024
          architecture  ['i386', 'x86_64']
        end

        define_hardware_profile '60' do
          cpu           12
          memory        32 * 1024
          storage       320 * 1024
          architecture  ['i386', 'x86_64']
        end

        define_hardware_profile '70' do
          cpu           16
          memory        48 * 1024
          storage       480 * 1024
          architecture  ['i386', 'x86_64']
        end

        define_hardware_profile '69' do
          cpu           16
          memory        64 * 1024
          storage       640 * 1024
          architecture  ['i386', 'x86_64']
        end

        define_hardware_profile '68' do
          cpu           24
          memory        96 * 1024
          storage       960 * 1024
          architecture  ['i386', 'x86_64']
        end

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

        def realms(credentials, opts={})
          safely do
            new_client(credentials).get('regions')['regions'].map do |r|
              Realm.new(
                :id => r['id'],
                :name => r['name'],
                :state => 'AVAILABLE',
                :limit => :unlimited
              )
            end
          end
        end

        # By default images will return list of 'all' images available
        # to launch.
        # With 'owner_id' you can filter them using 'global' and 'my_images'
        # values to get less images.
        #
        def images(credentials, opts={})
          unless opts[:id]
            filter = opts[:owner_id] ? { :filter => opts[:owner_id] } : {}
            img_arr = safely do
              new_client(credentials).get('images', filter)['images'].map do |i|
                convert_image(credentials, i)
              end
            end
            filter_on( img_arr, :architecture, opts )
          else
            safely do
              [convert_image(
                credentials,
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
            args.merge!(:region_id => opts[:realm_id]) if opts[:realm_id]
            args.merge!(:size_id => opts[:hwp_id]) if opts[:hwp_id]
            args.merge!(:name => opts[:name] || "inst#{Time.now.to_i}")
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

        exceptions do

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
              error_message = json_result['error_message'] || json_result['status']
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

        def convert_image(credentials, i)
          Image.new(
            :id => i['id'].to_s,
            :name => i['name'],
            :description => i['distribution'],
            :owner_id => 'global',
            :state => 'AVAILABLE',
            :architecture => extract_arch_from_name(i['name']),
            :hardware_profiles => hardware_profiles(credentials)
          )
        end

      end
    end
  end
end
