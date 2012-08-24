require 'rubygems'
require 'logger'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'
require 'pp'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative '../lib/deltacloud/api.rb'

ENV['RACK_ENV'] = 'test'

if ENV['COVERAGE']
  begin
    require 'simplecov'
  rescue LoadError
    warn "To generate code coverage you need to install 'simplecov' (gem install simplecov OR bundle)"
  end
end

require 'time'

# This code was originally copied from:
# https://github.com/jtrupiano/timecop/issues/8#issuecomment-1396047
#
# Since 'timecop' gem has broken 'timezone' support, this small monkey-patching
# on Time object seems to fix this issue.

unless Time.respond_to? :be
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
end

# Test helpers

def record_retries(name='')
  {
    :before => Proc.new { |r, &block|
      VCR.use_cassette("#{__name__}-#{name.empty? ? '' : "#{name}-"}#{r}", &block)
    }
  }
end

include Rack::Test::Methods

def status; last_response.status; end
def headers; last_response.headers; end
def response_body; last_response.body; end
def xml; Nokogiri::XML(response_body); end
def json; JSON::parse(response_body); end
def formats; [ 'application/xml', 'application/json', 'text/html' ]; end
def root_url(url=''); Deltacloud.default_frontend.root_url + url; end
