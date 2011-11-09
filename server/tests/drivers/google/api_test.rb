$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/common'

module GoogleTest

  class ApiTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_01_it_returns_entry_points
      get_auth_url '/api;driver=google/?force_auth=1'
      (last_xml_response/'/api').first[:driver].should == 'google'
      (last_xml_response/'/api/link').length.should > 0
    end

    def test_02_it_has_google_features
      get_url '/api;driver=google'
      features = (last_xml_response/'/api/link[@rel="buckets"]/feature').collect { |f| f[:name] }
      features.include?('bucket_location').should == true
      features.length.should == 1
    end

    def test_03_it_has_google_collections
      get_url '/api;driver=google'
      collections = (last_xml_response/'/api/link').collect { |f| f[:rel] }
      collections.include?('buckets').should == true
      collections.include?('drivers').should == true
      collections.length.should == 2
    end

  end
end
