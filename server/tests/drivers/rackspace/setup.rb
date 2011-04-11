ENV['API_DRIVER']   = "rackspace"
ENV['API_USER']     = 'michalfojtik'
ENV['API_PASSWORD'] = '47de1170d57eb8f11dba2f6e7fd26838'

require 'vcr'

DeltacloudTestCommon::record!

VCR.config do |c|
  c.cassette_library_dir = "#{File.dirname(__FILE__)}/../../../tests/drivers/rackspace/fixtures/"
  c.stub_with :webmock
  c.default_cassette_options = { :record => :none }
end

