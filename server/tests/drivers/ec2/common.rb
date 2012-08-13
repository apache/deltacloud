# Warning: RightHttpConnection has to be required before WebMock is required !!!
# Lets require that:
require 'right_http_connection'
require 'vcr'

# Freeze time, so EC2 signatures have all the same time
# This will avoid IncorrectSignature exceptions

# NOTE: This timestamp need to be changed when re-recording
#       the fixtures.

def credentials
  {
    :user => 'AKIAJYOQYLLOIWN5LQ3A',
    :password => 'Ra2ViYaYgocAJqPAQHxMVU/l2sGGU2pifmWT4q3H'
  }
end

unless Time.respond_to? :be
  require_relative '../../test_helper.rb'
end

Time.be(DateTime.parse("2012-07-30 11:05:00 +0000").to_s)

VCR.configure do |c|
  # NOTE: Empty this directory before re-recording
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.hook_into :webmock
  # Set this to :new_episodes when you want to 're-record'
  c.default_cassette_options = { :record => :new_episodes }
end
