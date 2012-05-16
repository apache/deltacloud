require 'rubygems'
require 'nokogiri'
require 'rack/test'

ENV['API_DRIVER'] = 'ec2'

#CONFIG = {
#  :username => 'AKIAI77KNAA7ZXRLL7GQ',
#  :password => 'idJ9vktNaDWAK0LWVVE/526ONvJmTl2Crto/s8Ok'
#}

CONFIG = {
  :username => 'mockuser',
  :password => 'mockpassword'
}

load File.join(File.dirname(__FILE__), '..', '..', '..', 'server', 'lib', 'deltacloud_rack.rb')

Deltacloud::configure do |server|
  server.root_url '/api'
  server.version '0.5.0'
  server.klass 'Deltacloud::API'
end.require_frontend!

require_relative './ec2_mock_driver'

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
