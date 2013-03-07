require 'vcr'

require_relative '../../test_helper'

# The configuration for RHEVM in ~/.deltacloud/config should look like
# this:
#    rhevm:
#      user: USERNAME
#      password: PASSWORD
#      provider: https://rhevm.example.com/api
#      preferred:
#        datacenter: UUID of a datacenter/realm
#        vm: UUID of an existing instance
#        template: UUID of an existing template
#
# Anything in the preferred part of the config is also written into
# ./fixtures/preferences.yml and used when playing back fixtures

if vcr_recording?
  Deltacloud::Test::config.save(:rhevm, File.dirname(__FILE__)) do |h|
    u = URI::parse(h["provider"])
    u.host = "rhevm.example.com"
    h["provider"] = u.to_s
  end
else
  Deltacloud::Test::config.load(:rhevm, File.dirname(__FILE__))
end

VCR.configure do |c|
  # NOTE: Empty this directory before re-recording
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.hook_into :webmock
  # Rewrite sensitive information before recording
  c.before_record do |i|
    u = URI::parse(i.request.uri)
    u.host = "rhevm.example.com"
    u.user = "fakeuser"
    u.password = "fakepassword"
    i.request.uri = u.to_s
  end
  c.default_cassette_options = {
    :record => vcr_record_mode,
    :match_requests_on => [ :method, :path, :query ]
  }
end
