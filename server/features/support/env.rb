require 'sinatra'
require 'server'
require 'rack/test'
require 'base64'

Sinatra::Application.set :environment, :test

CONFIG = {}
load 'features/support/configuration_mock.rb'

World do
  def app
    @app = Rack::Builder.new do
      run Sinatra::Application
    end
  end

  def replace_variables(str)
    CONFIG[$DRIVER].each_key.collect { |k| str.gsub!(/\<#{k.to_s.upcase}\>/, "#{CONFIG[$DRIVER][k]}") }
    return str
  end

  include Rack::Test::Methods
end

