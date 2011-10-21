ENV['API_DRIVER']   = "rackspace"
ENV['API_USER']     = 'mandreou'
ENV['API_PASSWORD'] = 'a4d531ef02a37dd32cac1e8e516df9eb'

require 'vcr'

DeltacloudTestCommon::record!

VCR.config do |c|
  c.cassette_library_dir = "#{File.dirname(__FILE__)}/../../../tests/drivers/rackspace/fixtures/"
  c.stub_with :webmock
  c.default_cassette_options = { :record => :new_episodes }
end

