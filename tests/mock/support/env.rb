require 'rubygems'
require 'nokogiri'
require 'rack/test'
load File.join(File.dirname(__FILE__), '..', '..', '..', 'server', 'lib', 'deltacloud_rack.rb')

Deltacloud::configure do |server|
  server.root_url '/api'
  server.version '0.5.0'
  server.klass 'Deltacloud::API'
end

Deltacloud.require_frontend!(:deltacloud)

CONFIG = {
  :username => 'mockuser',
  :password => 'mockpassword'
}

def output_xml
  Nokogiri::XML(last_response.body)
end

def app
  Rack::URLMap.new(
    "/" => Deltacloud::API.new,
    "/stylesheets" =>  Rack::Directory.new( "public/stylesheets" ),
    "/javascripts" =>  Rack::Directory.new( "public/javascripts" )
  )
end
