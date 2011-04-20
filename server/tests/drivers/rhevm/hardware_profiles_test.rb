$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/common'

module RHEVMTest

  class HardwareProfilesTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_01_it_returns_hardware_profiles
      get_auth_url '/api;driver=rhevm/hardware_profiles'
      (last_xml_response/'hardware_profiles/hardware_profile').length.should == 2
    end

    def test_02_each_hardware_profile_has_a_name
      get_auth_url '/api;driver=rhevm/hardware_profiles'
      (last_xml_response/'hardware_profiles/hardware_profile').each do |profile|
        (profile/'name').text.should_not == nil
        (profile/'name').text.should_not == ''
      end
    end

    def test_03_each_hardware_profile_has_correct_properties
      get_auth_url '/api;driver=rhevm/hardware_profiles'
      (last_xml_response/'hardware_profiles/hardware_profile').each do |profile|
        (profile/'property[@name="architecture"]').first[:value].should == 'x86_64'
        (profile/'property[@name="memory"]').first[:unit].should == 'MB'
        (profile/'property[@name="memory"]').first[:kind].should == 'range'
        (profile/'property[@name="storage"]').first[:unit].should == 'GB'
        (profile/'property[@name="storage"]').first[:kind].should == 'range'
      end
    end

    def test_04_it_returns_single_hardware_profile
      get_auth_url '/api;driver=rhevm/hardware_profiles/DESKTOP'
      (last_xml_response/'hardware_profile/name').first.text.should == 'DESKTOP'
      (last_xml_response/'hardware_profile/property[@name="architecture"]').first[:value].should == 'x86_64'
      (last_xml_response/'hardware_profile/property[@name="memory"]').first[:value].should == '512'
      (last_xml_response/'hardware_profile/property[@name="storage"]').first[:value].should == '1'
    end

    def test_05_it_filter_hardware_profiles
      get_auth_url '/api;driver=rhevm/hardware_profiles?architecture=i386'
      (last_xml_response/'hardware_profiles/hardware_profile').length.should == 0
      get_auth_url '/api;driver=rhevm/hardware_profiles?architecture=x86_64'
      (last_xml_response/'hardware_profiles/hardware_profile').length.should == 2
    end

  end
end
