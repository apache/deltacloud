SERVER_DIR = File::expand_path(File::join(File::dirname(__FILE__), "../../../server"))
Dir.chdir(SERVER_DIR)

require 'sinatra'
require 'rack/test'
require 'nokogiri'
require '../server/server'

Sinatra::Application.set :environment, :test
Sinatra::Application.set :root, SERVER_DIR

require '../server/lib/deltacloud/base_driver/mock_driver'

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
  
  prefixes = %W{ @prefix-start, @prefix-reboot, @prefix-stop, @prefix-create, @prefix-create-hwp}

  Before(prefixes.join(',')) do |scenario|
    prefix = scenario.source_tag_names.first.gsub(/@prefix-/, '')
    $scenario_prefix = prefix
  end

  After(prefixes.join(',')) do |scenario|
    $scenario_prefix = nil
  end

  include Rack::Test::Methods
end

