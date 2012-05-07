require 'rubygems'
require 'nokogiri'

SERVER_DIR = File::expand_path(File::join(File::dirname(__FILE__), "../../../server"))
$top_srcdir = SERVER_DIR
$:.unshift File::join($top_srcdir, 'lib')
Dir.chdir(SERVER_DIR)

API_VERSION = "9.9.9"
API_ROOT_URL = "/api"

ENV['API_DRIVER'] = 'ec2'
ENV.delete('API_VERBOSE')

load File.join($top_srcdir, 'lib', 'deltacloud', 'server.rb')

require 'rack/test'

CONFIG = {
  :username => 'mockuser',
  :password => 'mockpassword'
}

World do
  include Rack::Test::Methods

  def app
    @app = Rack::URLMap.new(
      "/" => Deltacloud::API.new,
      "/stylesheets" =>  Rack::Directory.new( "public/stylesheets" ),
      "/javascripts" =>  Rack::Directory.new( "public/javascripts" )
    )
  end

  def output_xml
    Nokogiri::XML(last_response.body)
  end

  Before do
    unless @no_header
      header 'Accept', 'application/xml;q=9'
    end
  end

  prefixes = %W{ @prefix-start, @prefix-reboot, @prefix-stop, @prefix-create, @prefix-create-hwp, @prefix-destroy, @prefix-actions}

  Before(prefixes.join(',')) do |scenario|
    prefix = scenario.source_tag_names.first.gsub(/@prefix-/, '')
    $scenario_prefix = prefix
  end

  After(prefixes.join(',')) do |scenario|
    $scenario_prefix = nil
  end

end
