require_relative File.join('..', '..', '..', 'lib', 'deltacloud_rack.rb')

unless Time.respond_to? :be
  require_relative '../../test_helper.rb'
end

# Set the default driver used for server API tests
#
ENV['API_DRIVER'] = 'mock'

# Setup Deltacloud::API Sinatra instance
#
unless Deltacloud::config[:cimi]
  Deltacloud::configure(:cimi) do |server|
    server.root_url '/cimi'
    server.version '1.0.0'
    server.klass 'CIMI::API'
    server.logger Rack::DeltacloudLogger.setup(ENV['API_LOG'], ENV['API_VERBOSE'])
  end

  Deltacloud.require_frontend!(:cimi)
end

def root_url(url=''); Deltacloud.config[:cimi].root_url + url; end
def formats; [ 'application/xml', 'application/json' ]; end
def json; JSON::parse(response_body); end
