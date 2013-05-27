require 'rubygems'
require 'require_relative' if RUBY_VERSION < "1.9"

ENV['RACK_ENV'] = 'test'
require_relative '../lib/initialize'

require 'minitest/autorun'
require_relative '../lib/deltacloud/api'

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
  Turn.config.format = :dot
rescue LoadError => e
  # We'll be fine
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

def vcr_record_mode
  (ENV['VCR_RECORD'] || :none).to_sym
end

def vcr_recording?
  vcr_record_mode != :none
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
        @hash = Hash.new do |hash, driver|
          if hash.has_key?(driver.to_s)
            hash[driver] = hash[driver.to_s]
          else
            hash[driver] = {
              "user" => "fakeuser",
              "password" => "fakepassword",
              "provider" => "fakeprovider"
            }
          end
        end
        begin
          @hash.merge!(YAML.load(File::open(fname)))
        rescue Errno::ENOENT
          # Ignore
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
        user = @hash[driver]["user"]
        password = @hash[driver]["password"]
        { :user => user, :password => password }
      end

      def driver(driver)
        user = @hash[driver.to_s]["user"]
        password = @hash[driver.to_s]["password"]
        provider = @hash[driver.to_s]["provider"]
        params = {:user => user, :password => password, :provider => provider}
        Deltacloud::new(driver, params)
      end

      def preferences(driver)
        @hash[driver.to_s]["preferred"]
      end

      def save(driver, dir, &block)
        h = @hash[driver.to_s].dup
        h["user"] = "fakeuser"
        h["password"] = "fakepassword"
        yield(h) if block_given?
        File::open(prefs_file(dir), "w") { |f| f.write(h.to_yaml) }
      end

      def load(driver, dir)
        @hash[driver.to_s] = YAML::load(File::open(prefs_file(dir), "r"))
      end

      private
      def prefs_file(dir)
        File.join(dir, 'fixtures', 'preferences.yml')
      end
    end

    def self.config
      Config::instance
    end
  end
end
