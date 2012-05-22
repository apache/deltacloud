require_relative './common'
require_relative '../../lib/deltacloud/api'

begin
  require 'arguments'
rescue LoadError
  puts "You don't have 'rdp-arguments' gems installed. (gem install rdp-arguments)"
  exit(1)
end
require 'pp'

describe 'Deltacloud drivers API' do

  before do
    @stderr = $stderr.clone
    $stderr = StringIO.new
  end

  after do
    $stderr = @stderr
  end

  it 'should pass the known method to Deltacloud driver' do
    Deltacloud.new(:mock).hardware_profiles.must_be_kind_of Array
    Deltacloud.new(:mock).hardware_profiles.wont_be_empty
  end

  it 'should raise NoMethodError when driver does not respond to method' do
    lambda { Deltacloud.new(:mock).non_existing_method }.must_raise NoMethodError
  end

  it 'should apply the credentials to methods that require them' do
    Deltacloud.new(:mock).realms.must_be_kind_of Array
    Deltacloud.new(:mock).realms.wont_be_empty
  end

  it 'should allow to use different drivers' do
    Deltacloud.new(:ec2).backend.must_be_instance_of Deltacloud::Drivers::Ec2::Ec2Driver
    Deltacloud.new(:mock).backend.must_be_instance_of Deltacloud::Drivers::Mock::MockDriver
  end

  it 'should support loading all supported drivers' do
    Deltacloud.drivers.keys.each do |key|
      Deltacloud.new(key).current_driver.must_equal key.to_s
    end
  end

  METHODS = {
    :firewalls => [[:credentials], [:opts, "{  }"]],
    :firewall  => [[:credentials], [:opts, "{  }"]],
    :keys    => [[:credentials], [:opts, "{  }"]],
    :key     => [[:credentials], [:opts]],
    :storage_snapshots => [[:credentials], [:opts, "{  }"]],
    :storage_snapshot  => [[:credentials], [:opts]],
    :storage_volumes => [[:credentials], [:opts, "{  }"]],
    :storage_volume  => [[:credentials], [:opts]],
    :realms    => [[:credentials], [:opts, "{  }"]],
    :realm     => [[:credentials], [:opts]],
    :images    => [[:credentials], [:opts, "{  }"]],
    :image     => [[:credentials], [:opts]],
    :instances => [[:credentials], [:opts, "{  }"]],
    :instance  => [[:credentials], [:opts]],
    :create_instance => [[:credentials], [:image_id], [:opts, "{  }"]],
    :destroy_instance => [[:credentials], [:id]],
    :stop_instance => [[:credentials], [:id]],
    :start_instance => [[:credentials], [:id]],
    :reboot_instance => [[:credentials], [:id]],
  }

  Deltacloud.drivers.keys.each do |key|
    METHODS.each do |m, definition|
      it "should have the correct parameters for the :#{m} method in #{key} driver" do
        next unless Deltacloud.new(key).backend.respond_to? m
        Arguments.names(Deltacloud.new(key).backend.class, m).must_equal definition
      end
    end
  end

end
