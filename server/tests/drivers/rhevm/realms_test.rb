$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/common'

module RHEVMTest

  class RealmsTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_01_it_returns_realms
      get_auth_url '/api;driver=rhevm/realms'
      (last_xml_response/'realms/realm').length.should == 1
    end

    def test_02_each_realm_has_a_name
      get_auth_url '/api;driver=rhevm/realms'
      (last_xml_response/'realms/realm').each do |profile|
        (profile/'name').text.should_not == nil
        (profile/'name').text.should_not == ''
        (profile/'name').text.should == 'Default'
      end
    end

    def test_03_it_returns_single_realm
      get_auth_url '/api;driver=rhevm/realms/us'
      (last_xml_response/'realm').first[:id].should == '0'
      (last_xml_response/'realm/name').first.text.should == 'Default'
      (last_xml_response/'realm/state').first.text.should == 'AVAILABLE'
    end

  end
end
