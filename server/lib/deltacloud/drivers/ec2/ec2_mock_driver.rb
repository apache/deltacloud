#
# Copyright (C) 2009,2010  Red Hat, Inc.
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

module RightAws
  class MockEc2
    
    def initialize(opts={})
    end

    def describe_images(id)
      load_fixtures_for(:images).select { |i| i[:aws_id].eql?(id) }
    end

    def describe_images_by_owner(id)
      load_fixtures_for(:images).select { |i| i[:aws_owner].eql?(id) }
    end

    def describe_images(opts={})
      load_fixtures_for(:images)
    end

    def describe_availability_zones(opts={})
      load_fixtures_for(:realms)
    end

    def describe_instances(opts={})
      instances = load_fixtures_for(:instances)
      instances.each_with_index do |instance, i|
        instances[i] = update_delayed_state(instance)
        return [instance] if opts and opts[:id] and instance[:aws_instance_id].eql?(opts[:id])
      end
      update_fixtures_for(:instances, instances)
      instances
    end

    def run_instances(image_id, min_count, max_count, group_ids, key_name, user_data='', addressing_type = nil, instance_type = nil, kernel_id = nil, ramdisk_id = nil, availability_zone = nil, block_device_mappings = nil)

      instances = load_fixtures_for(:instances)
      image = load_fixtures_for(:images).select { |img| img[:aws_id].eql?(image_id) }.first

      if availability_zone
        realm = load_fixtures_for(:realms).select { |realm| realm[:zone_name].eql?(availability_zone) }.first
      else
        realm = load_fixtures_for(:realms).first
      end

      raise Exception unless image
      raise Exception unless realm

      instance = { }
      instance[:aws_image_id] = image[:aws_id]
      instance[:aws_availability_zone] = realm[:zone_name]
      instance[:aws_instance_type] = instance_type
      instance[:aws_owner] = user_data
      instance[:aws_state] = 'pending'
      instance[:aws_reason] = ''
      instance[:dns_name] = "#{random_dns}-01-C9.usma2.compute.amazonaws.com"
      instance[:private_dns_name] = "#{random_dns}-02-P9.usma2.compute.amazonaws.com"
      instance[:aws_state_code] = "0"
      instance[:aws_key_name] = "staging"
      instance[:aws_kernel_id] = "aki-be3adfd7"
      instance[:aws_ramdisk_id] = "ari-ce34gad7"
      instance[:aws_groups] = ["default"]
      instance[:aws_instance_id] = random_instance_id
      instance[:aws_reservation_id] = "r-aabbccdd"
      instance[:aws_launch_time] = instance_time_format

      instances << instance

      update_fixtures_for(:instances, instances)

      return [instance]
    end


    def terminate_instances(id)
      update_instance_state(id, 'stopping', '80')
    end

    def reboot_instances(id)
      update_instance_state(id, 'pending', '0')
    end

    alias :destroy_instance :terminate_instances

    def describe_snapshots(opts={})
      load_fixtures_for(:storage_snapshot)
    end

    def describe_volumes(opts={})
      load_fixtures_for(:storage_volume)
    end

    private

    def driver_dir
      File::expand_path(File::join(File::dirname(__FILE__), '../../../../features/support/ec2'))
    end

    def fixtures_path
      File::expand_path(File::join(driver_dir, 'fixtures'))
    end

    def load_fixtures_for(collection)
      YAML.load_file(File::join(fixtures_path, "#{collection}.yaml"))
    end

    def update_fixtures_for(collection, new_data)
      File.open(File::join(fixtures_path, "#{collection}.yaml"), 'w' ) do |out|
        YAML.dump(new_data, out)
      end
      return new_data
    end

    def instance_time_format
      DateTime.now.to_s.gsub(/\+(.+)$/, '.000Z')
    end

    def random_instance_id
      id_1 = ("%.4s" % Time.now.to_i.to_s.reverse).reverse
      id_2 = ("%.3s" % Time.now.to_i.to_s.reverse)
      "i-#{id_1}f#{id_2}"
    end

    def random_dns
      "domU-#{rand(90)+10}-#{rand(90)+10}-#{rand(90)+10}-#{rand(90)+10}"
    end

    def update_delayed_state(instance)
      time = DateTime.now - DateTime.parse(instance[:aws_launch_time])
      hours, minutes, seconds, frac = Date.day_fraction_to_time(time)

      if (minutes>(rand(2)+1) or hours>0) and instance[:aws_state].eql?('pending')
        instance[:aws_state], instance[:aws_state_code] = 'running', '16'
      end

      if (minutes>(rand(1)+1) or hours>0) and instance[:aws_state].eql?('stopping')
        instance[:aws_state], instance[:aws_state_code] = 'stopped', '80'
      end

      return instance
    end

    def update_instance_state(id, state, state_code)
      instance = describe_instances(:id => id).first
      if instance
        instance[:aws_state], instance[:aws_state_code] = state, state_code
        instance[:aws_launch_time] = instance_time_format
        instances = load_fixtures_for(:instances)
        instances.each_with_index do |inst, i|
          instances[i] = instance if inst[:aws_instance_id].eql?(id)       
        end
        update_fixtures_for(:instances, instances)
        return instance
      else
        raise Exception
      end
    end

  end
end

Deltacloud::Drivers::EC2::EC2Driver.class_eval do
  alias_method :original_new_client, :new_client

  def new_client(credentials, opts={})
    if credentials.user != 'mockuser' and credentials.password != 'mockpassword'
      raise Deltacloud::AuthException.new
    end
    RightAws::MockEc2.new
  end

end
