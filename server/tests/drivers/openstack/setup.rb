ENV.delete 'API_VERBOSE'
ENV['API_DRIVER']   = "openstack"
ENV['API_USER']     = 'mfojtik'
ENV['API_PASSWORD'] = 'test'
ENV['API_PROVIDER'] = 'http://mfojtik-2.brq.redhat.com:8774/auth/1.1'

require 'vcr'
DeltacloudTestCommon::record!

VCR.config do |c|
  c.cassette_library_dir = "#{File.dirname(__FILE__)}/../../../tests/drivers/openstack/fixtures/"
  c.stub_with :webmock
  c.default_cassette_options = { :record => :new_episodes }
end

class WebMock::Config
  def net_http_connect_on_start
    true
  end
end
