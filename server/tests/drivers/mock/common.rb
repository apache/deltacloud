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
          use Rack::Static, :urls => ["/stylesheets", "/javascripts"], :root => "public"
          run Rack::Cascade.new([Deltacloud::API])
        end
      }
    end
  end
end
