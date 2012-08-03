require_relative File.join('..', '..', '..', 'lib', 'deltacloud_rack.rb')
require_relative '../../test_helper.rb'

# Setup CIMI::API Sinatra instance
#
Deltacloud::configure(:cimi) do |server|
  server.root_url '/cimi'
  server.version '1.0.0'
  server.klass 'CIMI::API'
  server.default_driver :mock
  server.logger Rack::DeltacloudLogger.setup(ENV['API_LOG'], ENV['API_VERBOSE'])
end

Deltacloud[:cimi].require!
Deltacloud[:cimi].default_frontend!

def formats; [ 'application/xml', 'application/json' ]; end
