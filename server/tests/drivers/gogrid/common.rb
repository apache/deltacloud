require 'vcr'

require_relative '../../test_helper.rb'

def credentials
  Deltacloud::Test::config.credentials("gogrid")
end

def fixed_image_id
  # A fixed image we use throughout the tests; if GoGrid ever removes it
  # we need to change it here
  "9928"
end

VCR.configure do |c|
  # NOTE: Empty this directory before re-recording
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.hook_into :webmock
  matcher = VCR.request_matchers.uri_without_param("api_key", "sig")
  c.register_request_matcher(:gogrid_matcher, &matcher)
  # Set this to :new_episodes to rerecord
  c.default_cassette_options[:record] =:none
  c.default_cassette_options[:match_requests_on] = [:method, :gogrid_matcher]
end
