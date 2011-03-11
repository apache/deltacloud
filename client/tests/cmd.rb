require 'rubygems'
require 'shoulda'
require 'tests/common'

include DeltaCloud::TestHelper

class CommandLineTest < Test::Unit::TestCase
  context "a command line client" do

    should "respond to --help argument" do
      assert_nothing_raised do
        base_client('--help')
      end
    end

    should "return API version with --version argument" do
      assert_match /Deltacloud API\(mock\) (\d+)\.(\d+)/, client('--version')
    end

    should "return list all collections with --list argument" do
      output = nil
      assert_nothing_raised do
        output = client('--list')
      end
      assert_not_nil output
      assert_match /images/, output
      assert_match /instances/, output
      assert_match /realms/, output
      assert_match /hardware_profiles/, output
    end

    should 'respond with proper error when accessing unknow collection' do
      output = client('unknown_collection')
      assert_match /^ERROR: Unknown collection/, output
    end

  end
end

class CmdRealmTest < Test::Unit::TestCase
  context "a realms" do

    should "be listed using realms argument" do
      output = nil
      assert_nothing_raised do
        output = client('realms')
      end
      assert_match /^us/m, output
      assert_match /^eu/m, output
    end

    should "be filtered using show --id argument" do
      output = nil
      assert_nothing_raised do
        output = client('realms show --id us')
      end
      assert_match /^us/, output
      assert_no_match /^eu/, output
    end

  end
end

class CmdHardwareProfilesTest < Test::Unit::TestCase
  context "a hardware profiles" do

    should "be listed using hardware_profiles argument" do
      output = nil
      assert_nothing_raised do
        output = client('hardware_profiles')
      end
      assert_no_warning output
      assert_match /^m1-small/m, output
      assert_match /^m1-large/m, output
      assert_match /^m1-xlarge/m, output
      assert_match /^opaque/m, output
    end

    should "be filtered using show --id argument" do
      output = nil
      assert_nothing_raised do
        output = client('hardware_profiles show --id m1-large')
      end
      assert_no_warning output
      assert_match /^m1-large/, output
      assert_no_match /^m1-small/, output
    end
  end
end

class CmdImagesTest < Test::Unit::TestCase

  context "a images" do

    should "be listed using images argument" do
      output = nil
      assert_nothing_raised do
        output = client('images')
      end
      assert_no_warning output
      assert_match /^img2/m, output
      assert_match /^img1/m, output
      assert_match /^img3/m, output
    end

    should "be filtered using show --id argument" do
      output = nil
      assert_nothing_raised do
        output = client('images show --id img2')
      end
      assert_no_warning output
      assert_match /^img2/m, output
      assert_no_match /^img1/m, output
    end

    should "be filtered using --arch argument" do
      output = nil
      assert_nothing_raised do
        output = client('images --arch x86_64')
      end
      assert_no_warning output
      assert_match /x86_64/, output
      assert_no_match /i386/, output
    end

  end

end

class CmdInstancesTest < Test::Unit::TestCase

  context 'an instances' do

    should 'be listed using instances argument' do
      output = nil
      assert_nothing_raised do
        output = client('instances')
      end
      assert_no_warning output
      assert_match /^inst1/, output
    end

    should 'be filtered using --id argument' do
      output = nil
      assert_nothing_raised do
        output = client('instances show --id inst0')
      end
      assert_no_warning output
      assert_match /^inst0/m, output
      assert_no_match /^inst1/m, output
    end

  end

  context 'an instance' do

    should 'be created supplying --image-id argument and -p argument' do
      output = nil
      assert_nothing_raised do
        output = client('instances create --image-id img1 -p m1-small')
      end
      assert_no_warning output
      assert_match /^inst(\d+)/, output
      @@created_instance_id = output.match(/^inst(\d+)/).to_a.first
    end

    should 'be rebooted using reboot operation' do
      output = nil
      assert_nothing_raised do
        output = client("instances reboot --id #{@@created_instance_id}")
      end
      assert_no_warning output
      assert_match /#{@@created_instance_id}/, output
      assert_match /RUNNING/, output
    end

    should 'be stopped using stop operation' do
      output = nil
      assert_nothing_raised do
        output = client("instances stop --id #{@@created_instance_id}")
      end
      assert_no_warning output
      assert_match /#{@@created_instance_id}/, output
      assert_match /STOPPED/, output
    end

    should 'be destroyed using destroy operation' do
      output = nil
      assert_nothing_raised do
        output = client("instances destroy --id #{@@created_instance_id}")
      end
      assert_no_warning output
    end

  end
end
