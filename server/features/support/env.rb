require 'sinatra'
require 'server'
require 'rack/test'
require 'nokogiri'

SERVER_DIR = File::expand_path(File::join(File::dirname(__FILE__), "../.."))
Sinatra::Application.set :environment, :test
Sinatra::Application.set :root, SERVER_DIR

ENV['API_DRIVER'] = "mock" unless ENV['API_DRIVER']

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

