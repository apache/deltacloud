require 'rubygems'
require 'nokogiri'

SERVER_DIR = File::expand_path(File::join(File::dirname(__FILE__), "../../../server"))
$top_srcdir = SERVER_DIR
$:.unshift File::join($top_srcdir, 'lib')
Dir.chdir(SERVER_DIR)

API_VERSION = "9.9.9"
API_ROOT_URL = "/api"

ENV['API_DRIVER'] = 'sbc'
ENV.delete('API_VERBOSE')

load File.join($top_srcdir, 'lib', 'deltacloud', 'server.rb')

require 'rack/test'

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
