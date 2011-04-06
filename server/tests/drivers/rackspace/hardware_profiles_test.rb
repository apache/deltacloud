$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/common'

module RackspaceTest

  class HardwareProfilesTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_01_it_returns_hardware_profiles
      do_xml_request '/api;driver=rackspace/hardware_profiles', {}, true
      (last_xml_response/'hardware_profiles/hardware_profile').length.should == 7
    end

    def test_02_each_hardware_profile_has_a_name
      do_xml_request '/api;driver=rackspace/hardware_profiles', {}, true
      (last_xml_response/'hardware_profiles/hardware_profile').each do |profile|
        (profile/'name').text.should_not == nil
        (profile/'name').text.should_not == ''
      end
    end

    def test_03_each_hardware_profile_has_correct_properties
      do_xml_request '/api;driver=rackspace/hardware_profiles', {}, true
      (last_xml_response/'hardware_profiles/hardware_profile').each do |profile|
        (profile/'property[@name="architecture"]').first[:value].should == 'x86_64'
        (profile/'property[@name="memory"]').first[:unit].should == 'MB'
        (profile/'property[@name="memory"]').first[:kind].should == 'fixed'
        (profile/'property[@name="storage"]').first[:unit].should == 'GB'
        (profile/'property[@name="storage"]').first[:kind].should == 'fixed'
      end
    end

    def test_04_it_returns_single_hardware_profile
      do_xml_request '/api;driver=rackspace/hardware_profiles/1', {}, true
      (last_xml_response/'hardware_profile/name').first.text.should == '1'
      (last_xml_response/'hardware_profile/property[@name="architecture"]').first[:value].should == 'x86_64'
      (last_xml_response/'hardware_profile/property[@name="memory"]').first[:value].should == '256'
      (last_xml_response/'hardware_profile/property[@name="storage"]').first[:value].should == '10'
    end

    def test_05_it_filter_hardware_profiles
      do_xml_request '/api;driver=rackspace/hardware_profiles?architecture=i386', {}, true
      (last_xml_response/'hardware_profiles/hardware_profile').length.should == 0
      do_xml_request '/api;driver=rackspace/hardware_profiles?architecture=x86_64', {}, true
      (last_xml_response/'hardware_profiles/hardware_profile').length.should == 7
    end

  end
end
