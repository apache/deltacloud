ENV['API_DRIVER']   = 'ec2'
ENV['API_USERNAME'] = 'AKIAI77KNAA7ZXRLL7GQ'
ENV['API_PASSWORD'] = 'idJ9vktNaDWAK0LWVVE/526ONvJmTl2Crto/s8Ok'
ENV['RACK_ENV']     = 'test'

load File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'deltacloud_rack.rb')

Deltacloud::configure do |server|
  server.root_url '/api'
  server.version '0.5.0'
  server.klass 'Deltacloud::API'
end.require_frontend!

require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'
require 'json'
require 'pp'
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

module Deltacloud
  module Test
    include Rack::Test::Methods

    def included?(sub)
      sub.class_eval do
        before do
          header 'Accept', 'application/xml'
        end
      end
    end

    def xml_response
      Nokogiri::XML(last_response.body)
    end

    def auth_as_mock
      authorize ENV['API_USERNAME'], ENV['API_PASSWORD']
    end

    def collection_url(collection)
      [Deltacloud[:root_url], collection.to_s].join('/')
    end

    def app
      Rack::Builder.new {
        map '/' do
          Timecop.freeze(FREEZED_TIME) do
            use Rack::Static, :urls => ["/stylesheets", "/javascripts"], :root => "public"
            run Rack::Cascade.new([Deltacloud::API])
          end
        end
      }
    end
  end
end
