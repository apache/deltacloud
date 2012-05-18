$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/rhevm/common'

module RHEVMTest

  class ApiTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Rack::Builder.new {
        map '/' do
          use Rack::Static, :urls => ["/stylesheets", "/javascripts"], :root => "public"
          run Rack::Cascade.new([Deltacloud::API])
        end
      }
    end

    def test_01_it_returns_entry_points
      get_auth_url '/api;driver=rhevm'
      (last_xml_response/'/api').first[:driver].should == 'rhevm'
      (last_xml_response/'/api/link').length.should > 0
    end

    def test_02_it_has_rhevm_features
      get_url '/api;driver=rhevm'
      features = (last_xml_response/'/api/link[@rel="instances"]/feature').collect { |f| f[:name] }
      features.include?('user_name').should == true
      features.include?('user_data').should == true
      features.length.should == 2
    end

    def test_03_it_has_rhevm_collections
      get_url '/api;driver=rhevm'
      collections = (last_xml_response/'/api/link').collect { |f| f[:rel] }
      collections.include?('instance_states').should == true
      collections.include?('instances').should == true
      collections.include?('images').should == true
      collections.include?('realms').should == true
      collections.include?('hardware_profiles').should == true
      collections.include?('storage_volumes').should == true
      collections.length.should == 7
    end

  end
end
