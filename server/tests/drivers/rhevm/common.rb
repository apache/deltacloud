require 'vcr'

require_relative '../../test_helper'

# Credentials used to access RHEV-M server
#
# NOTE: If these are changed, the VCR fixtures need to be re-recorded
#
def credentials
  {
    :user => 'vdcadmin@rhev.lab.eng.brq.redhat.com',
    :password => '123456',
    :provider => 'https://rhev30-dc.lab.eng.brq.redhat.com:8443/api;645e425e-66fe-4ac9-8874-537bd10ef08d'
  }
end

VCR.configure do |c|
  # NOTE: Empty this directory before re-recording
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.hook_into :webmock
  # Set this to :new_episodes when you want to 're-record'
  c.default_cassette_options = { :record => :none }
end
