SERVER_DIR = File::expand_path(File::join(File::dirname(__FILE__), "../../../server"))

$top_srcdir = SERVER_DIR
$:.unshift File::join($top_srcdir, 'lib')

ENV['API_DRIVER'] = 'mock'

Dir.chdir(SERVER_DIR)
require 'rubygems'
require 'nokogiri'
require 'deltacloud/server'
require 'rack/test'

Sinatra::Application.set :environment, :test
Sinatra::Application.set :root, SERVER_DIR

CONFIG = {
  :username => 'mockuser',
  :password => 'mockpassword'
}

ENV['RACK_ENV']     = 'test'

World do

  include Rack::Test::Methods

  def app
    @app = Rack::Builder.new do
      set :environment => :test
      set :loggining => true
      set :raise_errors => true
      set :show_exceptions => true
      run Sinatra::Application
    end
  end

  def output_xml
    Nokogiri::XML(last_response.body)
  end

  Before do
    unless @no_header
      header 'Accept', 'application/xml'
    end
  end

end
