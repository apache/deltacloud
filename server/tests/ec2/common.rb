require 'rubygems'
require 'require_relative'
require 'minitest/autorun'

require_relative File.join('..', '..', 'lib', 'deltacloud_rack.rb')
require_relative '../test_helper.rb'

# Setup Deltacloud::API Sinatra instance
#

Deltacloud::configure(:ec2) do |server|
  server.root_url '/'
  server.version '2012-04-01'
  server.klass 'Deltacloud::EC2::API'
  server.logger Rack::DeltacloudLogger.setup(ENV['API_LOG'], ENV['API_VERBOSE'])
  server.default_driver :mock
end

Deltacloud.require_frontend! :ec2

Deltacloud[:ec2].require!
Deltacloud[:ec2].default_frontend!

def root_url; Deltacloud.config[:ec2].root_url; end
