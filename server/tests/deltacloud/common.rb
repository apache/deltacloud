require 'logger'
require 'rack/test'
require 'nokogiri'

require_relative File.join('..', '..', 'lib', 'deltacloud_rack.rb')

include Rack::Test::Methods

def status; last_response.status; end
def headers; last_response.headers; end
def response_body; last_response.body; end
def xml; Nokogiri::XML(response_body); end
def root_url; Deltacloud.config[:deltacloud].root_url; end
def formats; [ 'application/xml', 'application/json', 'text/html' ]; end

# Set the default driver used for server API tests
#
ENV['API_DRIVER'] = 'mock'
ENV['RACK_ENV']   = 'test'

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
