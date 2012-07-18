ENV['API_DRIVER']   = 'ec2'
ENV['TESTS_API_USERNAME'] = 'AKIAIZ63KHGXIWDMBY6Q'
ENV['TESTS_API_PASSWORD'] = 'zUfBCbML2S6pXKS44eEEXw0Cf/G8z9hMSxP2hcLV'
ENV['RACK_ENV']     = 'test'

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/minitest_common'

require 'vcr'
require 'timecop'

VCR.configure do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.hook_into :webmock
  c.default_cassette_options = { :record => :new_episodes }
  #c.default_cassette_options = { :record => :none }
end

# Let's set time that timecop will use to freeze
# Time.now will then return this time instead of 'real' system time

FREEZED_TIME = DateTime.parse("2012-05-31 12:58:00 +0200")
Timecop.freeze(FREEZED_TIME)
