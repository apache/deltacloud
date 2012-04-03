ENV.delete 'API_VERBOSE'
ENV['API_DRIVER']   = "openstack"
ENV['API_USER']     = 'foo@bar.com+foo@bar.com-default-tenant'
ENV['API_PASSWORD'] = 'Not_a_real_password!1'
ENV['API_PROVIDER'] = 'https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/'

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
