SERVER_DIR = File::expand_path(File::join(File::dirname(__FILE__), "../../../server"))
Dir.chdir(SERVER_DIR)

require 'sinatra'
require 'rack/test'
require 'nokogiri'
require '../server/server'

Sinatra::Application.set :environment, :test
Sinatra::Application.set :root, SERVER_DIR

CONFIG = {
  :username => 'mockuser',
  :password => 'mockpassword'
}

World do

  def app
    @app = Rack::Builder.new do
      set :logging, true
      set :raise_errors, true
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

  include Rack::Test::Methods
end

