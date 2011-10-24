$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/common'

module OpenstackTest

  class ApiTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_01_it_returns_entry_points
      get_auth_url '/api;driver=openstack/?force_auth=1'
      (last_xml_response/'/api').first[:driver].should == 'openstack'
      (last_xml_response/'/api/link').length.should > 0
    end

    def test_02_it_has_openstack_features
      get_url '/api;driver=openstack'
      features = (last_xml_response/'/api/link[@rel="instances"]/feature').collect { |f| f[:name] }
      features.include?('user_name').should == true
      features.include?('authentication_password').should == true
      features.include?('user_files').should == true
      features.length.should == 3
    end

    def test_03_it_has_openstack_collections
      get_url '/api;driver=openstack'
      collections = (last_xml_response/'/api/link').collect { |f| f[:rel] }
      collections.include?('instance_states').should == true
      collections.include?('instances').should == true
      collections.include?('images').should == true
      collections.include?('buckets').should == true
      collections.include?('realms').should == true
      collections.include?('hardware_profiles').should == true
      collections.length.should == 7
    end

  end
end
