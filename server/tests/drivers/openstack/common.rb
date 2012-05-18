ENV['API_DRIVER']   = "openstack"
ENV['API_USER']     = 'foo@bar.com+foo@bar.com-default-tenant'
ENV['API_PASSWORD'] = 'Not_a_real_password!1'
ENV['API_PROVIDER'] = 'https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/'

load File.join(File.dirname(__FILE__), '..', '..', 'common.rb')
require 'vcr'

DeltacloudTestCommon::record!

VCR.config do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.stub_with :webmock
  c.default_cassette_options = { :record => :none }
end

class WebMock::Config
  def net_http_connect_on_start
    true
  end
end
