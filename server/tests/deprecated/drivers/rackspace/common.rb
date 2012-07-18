load File.join(File.dirname(__FILE__), '..', '..', 'common.rb')

ENV['API_DRIVER']   = "rackspace"
ENV['API_USER']     = 'mandreou'
ENV['API_PASSWORD'] = 'a4d531ef02a37dd32cac1e8e516df9eb'

require 'vcr'

DeltacloudTestCommon::record!

VCR.config do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.stub_with :webmock
  c.default_cassette_options = { :record => :none }
end

