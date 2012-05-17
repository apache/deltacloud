ENV['API_USER']     = 'vdcadmin@rhev.lab.eng.brq.redhat.com'
ENV['API_PASSWORD'] = '123456'
ENV['API_PROVIDER'] = 'https://rhev30-dc.lab.eng.brq.redhat.com:8443/rhevm-api;645e425e-66fe-4ac9-8874-537bd10ef08d'

require 'vcr'

VCR.config do |c|
  c.cassette_library_dir = "#{File.dirname(__FILE__)}/fixtures/"
  c.stub_with :webmock
  c.default_cassette_options = { :record => :none }
end
