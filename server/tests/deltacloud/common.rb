require_relative '../test_helper.rb'
require_relative File.join('..', '..', 'lib', 'deltacloud_rack.rb')

# Setup Deltacloud::API Sinatra instance

Deltacloud::configure do |server|
  server.root_url '/api'
  server.version '1.0.0'
  server.klass 'Deltacloud::API'
  server.logger Rack::DeltacloudLogger.setup(ENV['API_LOG'], ENV['API_VERBOSE'])
  server.default_driver :mock
end

Deltacloud.require_frontend!
