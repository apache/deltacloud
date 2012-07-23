# Make less noise to console
ENV['RACK_ENV'] ||= 'test'

# Warning: RightHttpConnection has to be required before WebMock is required !!!
# Lets require that:
require 'right_http_connection'

require 'vcr'
require 'time'

# This code was originally copied from:
# https://github.com/jtrupiano/timecop/issues/8#issuecomment-1396047
#
# Since 'timecop' gem has broken 'timezone' support, this small monkey-patching
# on Time object seems to fix this issue.

class Time
  module TimeMock
    attr_accessor :mock_time

    def mock_now
      @mock_time || Time.original_now
    end

    def be(a_time)
      @mock_time = Time.parse(a_time)
    end

  end

  class << self
    include TimeMock
    alias_method :original_now, :now
    alias_method :now, :mock_now
  end
end

# Freeze time, so EC2 signatures have all the same time
# This will avoid IncorrectSignature exceptions

Time.be(DateTime.parse("2012-07-23 12:21:00 +0000").to_s)

VCR.configure do |c|
  # NOTE: Empty this directory before re-recording
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.hook_into :webmock
  # Set this to :new_epizodes when you want to 're-record'
  c.default_cassette_options = { :record => :none }
end

# Some test scenarios use .wait_for! method that do multiple retries
# for requests. We need to deal with that passing a Proc that use
# different cassette for each request

def record_retries(name='')
  {
    :before => Proc.new { |r, &block|
      VCR.use_cassette("#{__name__}-#{name.empty? ? '' : "#{name}-"}#{r}", &block)
    }
  }
end
