ENV['API_USER']     = 'rhev-m@deltacloud.local'
ENV['API_PASSWORD'] = 'RedHat001'
ENV['API_PROVIDER'] = 'https://rhev-dc.lab.eng.brq.redhat.com:8443/rhevm-api-powershell'

require 'vcr'

DeltacloudTestCommon::record!

VCR.config do |c|
  c.cassette_library_dir = 'tests/drivers/rhevm/fixtures/'
  c.stub_with :webmock
  c.default_cassette_options = { :record => :none }
end

