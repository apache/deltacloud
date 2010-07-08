require 'sinatra'
require 'server'
require 'rack/test'

SERVER_DIR = File::expand_path(File::join(File::dirname(__FILE__), "../.."))

Sinatra::Application.set :environment, :test
Sinatra::Application.set :root, SERVER_DIR

CONFIG = {}
load "features/support/configuration_mock.rb"

World do
  def app
    @app = Rack::Builder.new do
      ENV['API_DRIVER'] = "mock"
      run Sinatra::Application
    end
  end

  def replace_variables(str)
    CONFIG[$DRIVER].keys.collect { |k| str.gsub!(/\<#{k.to_s.upcase}\>/, "#{CONFIG[$DRIVER][k]}") }
    return str
  end

  include Rack::Test::Methods
end

