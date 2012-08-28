# Warning: RightHttpConnection has to be required before WebMock is required !!!
# Lets require that:
require 'right_http_connection'
require 'vcr'

require_relative '../../test_helper.rb'

def credentials
  Deltacloud::Test::config.credentials('ec2')
end

VCR.configure do |c|
  # NOTE: Empty this directory before re-recording
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.hook_into :webmock
  matcher = VCR.request_matchers.uri_without_param("AWSAccessKeyId",
                                                   "Signature", "Timestamp")
  c.register_request_matcher(:ec2_matcher, &matcher)
  c.default_cassette_options = { :record => :none, :match_requests_on => [:method, :ec2_matcher] }
end
