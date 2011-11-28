require 'rubygems'
require 'nokogiri'

ENV['API_DRIVER'] = 'mock'
ENV['API_FRONTEND'] = 'cimi'
ENV.delete('API_VERBOSE')

$top_srcdir = File.join(File.dirname(__FILE__), '..', '..', '..', '..')
$:.unshift File.join($top_srcdir, 'lib')

load File.join($top_srcdir, 'lib', 'cimi', 'server.rb')

require 'rack/test'

def last_xml_response
  Nokogiri::XML(last_response.body)
end

def app
  Sinatra::Application
end
