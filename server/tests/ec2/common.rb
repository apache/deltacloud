require_relative File.join('..', '..', 'lib', 'deltacloud_rack.rb')

# Set the default driver used for server API tests
#
ENV['API_DRIVER'] = 'mock'

# Setup Deltacloud::API Sinatra instance
#
unless Deltacloud::config[:ec2]
  Deltacloud::configure(:ec2) do |server|
    server.root_url '/'
    server.version '2012-04-01'
    server.klass 'Deltacloud::EC2::API'
    server.logger Rack::DeltacloudLogger.setup(ENV['API_LOG'], ENV['API_VERBOSE'])
  end
  Deltacloud.require_frontend! :ec2
end

def root_url; Deltacloud.config[:ec2].root_url; end
