require 'rubygems'
require 'logger'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'
require 'pp'
require 'require_relative' if RUBY_VERSION < '1.9'

require 'singleton'

ENV['RACK_ENV'] = 'test'

require_relative '../lib/initialize'
require_relative '../lib/deltacloud/api.rb'

if ENV['COVERAGE']
  begin
    require 'simplecov'
  rescue LoadError
    warn "To generate code coverage you need to install 'simplecov' (gem install simplecov OR bundle)"
  end
end

# Make the test output more nice and readable
#
begin
  require 'turn'
rescue LoadError => e
  warn "[WARN] The 'turn' gem is not available. (#{e.message})"
end

begin
  require "minitest/reporters"
  MiniTest::Reporters.use!(MiniTest::Reporters::JUnitReporter.new) if !ENV['BUILD_NUMBER'].nil?
rescue LoadError
end

def record_retries(name='', opts = {})
  opts[:before] = Proc.new { |r, &block|
    VCR.use_cassette("#{__name__}-#{name.empty? ? '' : "#{name}-"}#{r}", &block)
  }
  if VCR.configuration.default_cassette_options[:record] == :none
    opts[:time_between_retry] = 0
  end
  opts
end

include Rack::Test::Methods

def run_frontend(frontend=:deltacloud)
  Rack::Builder.new {
    use Rack::MatrixParams
    map Deltacloud[frontend].root_url do
      use Rack::MatrixParams
      run Deltacloud[frontend].klass
    end
  }.to_app
end

def status; last_response.status; end
def headers; last_response.headers; end
def response_body; last_response.body; end
def xml; Nokogiri::XML(response_body); end
def json; JSON::parse(response_body); end
def formats; [ 'application/xml', 'application/json', 'text/html' ]; end
def root_url(url=''); Deltacloud.default_frontend.root_url + url; end

module Deltacloud
  module Test
    class Config
      include Singleton

      def initialize
        fname = ENV["CONFIG"] || File::expand_path("~/.deltacloud/config")
        begin
          @hash = YAML.load(File::open(fname))
        rescue Errno::ENOENT
          @hash = {}
        end
      end

      # Read credentials from ${HOME/.deltacloud/config if found.
      # e.g.:
      # cat ${HOME/.deltacloud/config
      # rhevm:
      #   user:     'user@domain'
      #   password: 'mypassword'
      #   provider: 'https://16.0.0.7/api;b9bb11c2-f397-4f41-a57b-7ac15a894779'
      # mock:
      #   user: mockuser
      #   password: mockpassword
      #   provider: compute
      def credentials(driver)
        driver = driver.to_s
        if @hash.has_key?(driver)
          user = @hash[driver]["user"]
          password = @hash[driver]["password"]
        else
          user = "fakeuser"
          password = "fakepassword"
        end
        { :user => user, :password => password }
      end

      def driver(driver, provider = nil)
        if @hash.has_key?(driver.to_s)
          user = @hash[driver.to_s]["user"]
          password = @hash[driver.to_s]["password"]
          provider = @hash[driver.to_s]["provider"] unless provider
          params = {:user => user, :password => password, :provider => provider}
        else
          provider = "fakeprovider" unless provider
          params = { :user => "fakeuser", :password => "fakepassword", :provider => provider }
        end
        Deltacloud::new(driver, params)
      end

    end

    def self.config
      Config::instance
    end
  end
end
