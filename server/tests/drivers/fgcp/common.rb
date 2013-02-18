require 'vcr'

require 'require_relative' if RUBY_VERSION < '1.9'
require_relative '../../test_helper.rb'


# Credentials used to access FGCP server
#
ENV['FGCP_CERT_DIR'] =  File.join(File.dirname(__FILE__), 'cert')
def credentials
  {
    :user => 'fgcp-testuser',
    :password => 'fgcp-password',
  }
end

#require 'turn' #internal_use_only
#Turn.config.format = :outline #internal_use_only


VCR.configure do |c|
  # NOTE: Empty this directory before re-recording
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.hook_into :webmock
  c.default_cassette_options = {
    :record => :new_episodes,
#    :record => :none,
    :match_requests_on => [:method,
    VCR.request_matchers.uri_without_param(:Signature, :AccessKeyId)]
  }
  #c.debug_logger = File.open(File.join('log', 'vcr.log'), 'w')
end
