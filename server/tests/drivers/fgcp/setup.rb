ENV.delete 'API_VERBOSE'
ENV['API_DRIVER']   = "fgcp"
ENV['API_USER']     = 'cert-dir'
ENV['API_PASSWORD'] = 'secret'

require 'vcr'
DeltacloudTestCommon::record!

VCR.config do |c|
  c.cassette_library_dir = "#{File.dirname(__FILE__)}/../../../tests/drivers/fgcp/fixtures/"
  c.stub_with :webmock
  c.default_cassette_options = { :record => :new_episodes }
end
