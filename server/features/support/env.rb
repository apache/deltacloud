require 'sinatra'
require 'server'
require 'rack/test'

SERVER_DIR = File::expand_path(File::join(File::dirname(__FILE__), "../.."))

Sinatra::Application.set :environment, :test
Sinatra::Application.set :root, SERVER_DIR

ENV['API_DRIVER'] = "mock" unless ENV['API_DRIVER']
CONFIG = YAML::load_file(File::join('features', 'support', ENV['API_DRIVER'], 'config.yaml'))

World do
  def app
    @app = Rack::Builder.new do
      set :logging, true
      run Sinatra::Application
    end
 end

  def replace_variables(str)
    CONFIG.keys.collect { |k| str.gsub!(/\<#{k.to_s.upcase}\>/, "#{CONFIG[k]}") }
    return str
  end

  Before do
    header 'Accept', 'application/xml'
  end

  include Rack::Test::Methods

end

