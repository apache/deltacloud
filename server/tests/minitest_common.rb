load File.join(File.dirname(__FILE__), '..', 'lib', 'deltacloud_rack.rb')

Deltacloud::configure do |server|
  server.root_url '/api'
  server.version '1.0.0'
  server.klass 'Deltacloud::API'
end

Deltacloud.require_frontend!(:deltacloud)

require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'
require 'json'
require 'pp'

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

    def root_url
      Deltacloud[:deltacloud].root_url
    end

    def api_version
      Deltacloud[:deltacloud].version
    end

    def authenticate
      authorize ENV['TESTS_API_USERNAME'], ENV['TESTS_API_PASSWORD']
    end

    def collection_url(collection)
      [root_url, collection.to_s].join('/')
    end

    def app
      Rack::Builder.new {
        map '/' do
          use Rack::Static, :urls => ["/stylesheets", "/javascripts"], :root => "public"
          run Rack::Cascade.new([Deltacloud::API])
        end
      }
    end
  end
end
