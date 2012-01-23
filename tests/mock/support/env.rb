require 'rubygems'
require 'nokogiri'

SERVER_DIR = File::expand_path(File::join(File::dirname(__FILE__), "../../../server"))
$top_srcdir = SERVER_DIR
$:.unshift File::join($top_srcdir, 'lib')
Dir.chdir(SERVER_DIR)

ENV['API_DRIVER'] = 'mock'
ENV.delete('API_VERBOSE')
load File.join($top_srcdir, 'lib', 'deltacloud', 'server.rb')

require 'rack/test'

CONFIG = {
  :username => 'mockuser',
  :password => 'mockpassword'
}

def output_xml
  Nokogiri::XML(last_response.body)
end

def app
  Sinatra::Application
end
