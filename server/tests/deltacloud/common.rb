require_relative File.join('..', '..', 'lib', 'deltacloud_rack.rb')

# Set the default driver used for server API tests
#
ENV['API_DRIVER'] = 'mock'

# Setup Deltacloud::API Sinatra instance
#
unless Deltacloud::config[:deltacloud]
  Deltacloud::configure do |server|
    server.root_url '/api'
    server.version '1.0.0'
    server.klass 'Deltacloud::API'
    server.logger Rack::DeltacloudLogger.setup(ENV['API_LOG'], ENV['API_VERBOSE'])
  end

  Deltacloud.require_frontend!
end

def root_url; Deltacloud.config[:deltacloud].root_url; end
