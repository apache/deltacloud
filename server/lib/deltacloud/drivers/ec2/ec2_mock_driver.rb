module RightAws
  class MockEc2
    
    def initialize(opts={})
    end

    def describe_images(id)
      images = load_fixtures_for(:images)
      return images.select { |i| i[:aws_id].eql?(id) }
    end

    def describe_images_by_owner(id)
      images = load_fixtures_for(:images)
      return images.select { |i| i[:aws_owner].eql?(id) }
    end

    def describe_images(opts={})
      images = load_fixtures_for(:images)
      return images
    end

    def describe_availability_zones(opts={})
      load_fixtures_for(:realms)
    end

    def describe_instances(opts={})
      instances = load_fixtures_for(:instances)
      instances.each_with_index do |instance, i|
        t1 = DateTime.now - DateTime.parse(instance[:aws_launch_time])
        hours, minutes, seconds, frac = Date.day_fraction_to_time(t1)
        if (minutes>3 or hours>0) and instance[:aws_state].eql?('pending')
          instance[:aws_state] = 'running'
          instance[:aws_state_code] = '16'
          instances[i] = instance
        end
        if (minutes>2 or hours>0) and instance[:aws_state].eql?('stopping')
          instance[:aws_state] = 'stopped'
          instance[:aws_state_code] = '80'
          instances[i] = instance
        end
        if opts and opts[:id]
          if instance[:aws_instance_id].eql?(opts[:id])
            return [instance]
          end
        end
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

      instance = { }
      instance[:aws_image_id] = image[:aws_id]
      instance[:aws_availability_zone] = realm[:zone_name]
      instance[:aws_instance_type] = instance_type
      instance[:aws_owner] = user_data
      instance[:aws_state] = 'pending'
      instance[:aws_launch_time] = DateTime.now.to_s.gsub(/\+(.+)$/, '.000Z')
      instance[:aws_reason] = ''
      instance[:dns_name] = "domU-#{rand(100)+10}-#{rand(100)+10}-#{rand(100)+10}-#{rand(100)+10}-01-C9.usma2.compute.amazonaws.com"
      instance[:private_dns_name] = "domU-#{rand(100)+10}-#{rand(100)+10}-#{rand(100)+10}-#{rand(100)+10}-02-P9.usma2.compute.amazonaws.com"
      instance[:aws_state_code] = "0"
      instance[:aws_key_name] = "staging"
      instance[:aws_kernel_id] = "aki-be3adfd7"
      instance[:aws_groups] = ["default"]
      instance[:aws_ramdisk_id] = "ari-ce34gad7"
      id_1 = ("%.4s" % Time.now.to_i.to_s.reverse).reverse
      id_2 = ("%.3s" % Time.now.to_i.to_s.reverse)
      instance[:aws_instance_id] = "i-#{id_1}f#{id_2}"
      instance[:aws_reservation_id] = "r-aabbccdd"

      instances << instance
      update_fixtures_for(:instances, instances)

      return [instance]
    end


    def terminate_instances(id)
      instances = load_fixtures_for(:instances)
      ti = nil
      instances.each_with_index do |instance, i|
        if instance[:aws_instance_id].eql?(id)
          instance[:aws_state] = 'stopping'
          instance[:aws_state_code] = '64'
          instance[:aws_launch_time] = DateTime.now.to_s.gsub(/\+(.+)$/, '.000Z')
          instances[i] = instance
          ti = i
          break
        end
      end
      update_fixtures_for(:instances, instances)
      return instances[ti]
    end

    alias :destroy_instance :terminate_instances
    
    def reboot_instances(id)
      instances = load_fixtures_for(:instances)
      ti = nil
      instances.each_with_index do |instance, i|
        if instance[:aws_instance_id].eql?(id)
          instance[:aws_state] = 'pending'
          instance[:aws_state_code] = '0'
          instance[:aws_launch_time] = DateTime.now.to_s.gsub(/\+(.+)$/, '.000Z')
          instances[i] = instance
          ti = i
          break
        end
      end
      update_fixtures_for(:instances, instances)
      return instances[ti]
    end

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

    def load_fixtures_for(collection)
      YAML.load_file(File::join(File::expand_path(File::join(driver_dir, 'fixtures')), "#{collection}.yaml"))
    end

    def update_fixtures_for(collection, new_data)
      File.open(File::join(File::expand_path(File::join(driver_dir, 'fixtures')), "#{collection}.yaml"), 'w' ) do |out|
        YAML.dump(new_data, out)
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
