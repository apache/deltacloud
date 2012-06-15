require 'rubygems'
require 'nokogiri'
require 'rack/test'

ENV['API_DRIVER'] = 'sbc'

load File.join(File.dirname(__FILE__), '..', '..', '..', 'server', 'lib', 'deltacloud_rack.rb')

Deltacloud::configure do |server|
  server.root_url '/api'
  server.version '1.0.0'
  server.klass 'Deltacloud::API'
end.require_frontend!

module Rack
  module Test
    class Session
      def headers
        @headers
      end
    end
  end
  class MockSession
    def set_last_response(response)
      @last_response = response
    end
  end
end

CONFIG = {
  :username => 'mockuser',
  :password => 'mockpassword'
}

def output_xml
  Nokogiri::XML(last_response.body)
end

def xml
  Nokogiri::XML(last_response.body)
end

def app
  Rack::URLMap.new(
    "/" => Deltacloud::API.new,
    "/stylesheets" =>  Rack::Directory.new( "public/stylesheets" ),
    "/javascripts" =>  Rack::Directory.new( "public/javascripts" )
  )
end
