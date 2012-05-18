$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/openstack/common'

module OpenstackTest

  class HardwareProfilesTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Rack::Builder.new {
        map '/' do
          use Rack::Static, :urls => ["/stylesheets", "/javascripts"], :root => "public"
          run Rack::Cascade.new([Deltacloud::API])
        end
      }
    end

    def test_01_it_returns_hardware_profiles
      get_auth_url '/api;driver=openstack/hardware_profiles'
      (last_xml_response/'hardware_profiles/hardware_profile').length.should > 0
    end

    def test_02_each_hardware_profile_has_a_name
      get_auth_url '/api;driver=openstack/hardware_profiles'
      (last_xml_response/'hardware_profiles/hardware_profile').each do |profile|
        (profile/'name').text.should_not == nil
        (profile/'name').text.should_not == ''
      end
    end

    def test_03_each_hardware_profile_has_correct_properties
      get_auth_url '/api;driver=openstack/hardware_profiles'
      (last_xml_response/'hardware_profiles/hardware_profile').each do |profile|
        (profile/'property[@name="architecture"]').first[:value].should == 'x86_64'
        (profile/'property[@name="memory"]').first[:unit].should == 'MB'
        (profile/'property[@name="memory"]').first[:kind].should == 'fixed'
        (profile/'property[@name="storage"]').first[:unit].should == 'GB'
        (profile/'property[@name="storage"]').first[:kind].should == 'fixed'
      end
      hwp = ((last_xml_response/'hardware_profiles/hardware_profile').first)
      @@hwp = { :id => hwp[:id],
                :arch => (hwp/'property[@name="architecture"]').first[:value],
                :mem => (hwp/'property[@name="memory"]').first[:value],
                :disk => (hwp/'property[@name="storage"]').first[:value] }
      @@no_of_profiles = (last_xml_response/'hardware_profiles/hardware_profile').length
    end

    def test_04_it_returns_single_hardware_profile
      get_auth_url "/api;driver=openstack/hardware_profiles/#{@@hwp[:id]}"
      (last_xml_response/'hardware_profile/name').first.text.should == @@hwp[:id]
      (last_xml_response/'hardware_profile/property[@name="architecture"]').first[:value].should == @@hwp[:arch]
      (last_xml_response/'hardware_profile/property[@name="memory"]').first[:value].should == @@hwp[:mem]
      (last_xml_response/'hardware_profile/property[@name="storage"]').first[:value].should == @@hwp[:disk]
    end

    def test_05_it_filter_hardware_profiles
      get_auth_url '/api;driver=openstack/hardware_profiles?architecture=i386'
      (last_xml_response/'hardware_profiles/hardware_profile').length.should == 0
      get_auth_url '/api;driver=openstack/hardware_profiles?architecture=x86_64'
      (last_xml_response/'hardware_profiles/hardware_profile').length.should == @@no_of_profiles
    end

  end
end
