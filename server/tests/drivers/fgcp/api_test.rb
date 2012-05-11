$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/common'

module FGCPTest

  class ApiTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_01_it_returns_entry_points
      get_auth_url '/api;driver=fgcp/?force_auth=1'
      (last_xml_response/'/api').first[:driver].should == 'fgcp'
      (last_xml_response/'/api/link').length.should > 0
    end

    def test_02_it_has_fgcp_instance_features
      get_url '/api;driver=fgcp'
      features = (last_xml_response/'/api/link[@rel="instances"]/feature').collect { |f| f[:name] }
      features.include?('user_name').should == true
      features.include?('authentication_password').should == true
      features.length.should == 2
    end

    def test_03_it_has_fgcp_image_features
      get_url '/api;driver=fgcp'
      features = (last_xml_response/'/api/link[@rel="images"]/feature').collect { |f| f[:name] }
      features.include?('user_name').should == true
      features.include?('user_description').should == true
      features.length.should == 2
    end

    def test_04_it_has_fgcp_collections
      get_url '/api;driver=fgcp'
      collections = (last_xml_response/'/api/link').collect { |f| f[:rel] }
      collections.include?('instance_states').should == true
      collections.include?('instances').should == true
      collections.include?('images').should == true
      collections.include?('realms').should == true
      collections.include?('hardware_profiles').should == true
      collections.length.should == 6
    end

  end
end
