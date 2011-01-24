$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/common'

require 'drivers'
require 'deltacloud/drivers/mock/mock_driver'

module DeltacloudUnitTest
  class ApiTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def setup
      @app ||= Sinatra::Application
      @driver ||= Deltacloud::Drivers::Mock::MockDriver.new
    end

    def teardown
      @app = nil
      @driver = nil
    end

    def test_params
      op = @app.collections[:instances].operations[:create]
      op.params.keys =~ [:realm_id, :image_id, :hwp_id]
    end

    def test_effective_params
      features = @driver.features(:instances).collect { |f| f.name }
      features.should =~ [:hardware_profiles, :user_name, :authentication_key]

      op = @app.collections[:instances].operations[:create]
      op.effective_params(@driver).keys.should =~ [:image_id, :hwp_memory, :hwp_id, :keyname, :name, :hwp_storage, :realm_id]

      op.params.keys =~ [:realm_id, :image_id, :hwp_id]
    end
  end
end
