SERVER_DIR = File::expand_path(File::join(File::dirname(__FILE__), "../../../server"))
Dir.chdir(SERVER_DIR)

ENV['API_DRIVER'] = 'ec2'

require 'rubygems'
require 'nokogiri'
require '../server/server'
require 'rack/test'

Sinatra::Application.set :environment, :test
Sinatra::Application.set :root, SERVER_DIR

require '../server/lib/deltacloud/base_driver/mock_driver'

CONFIG = {
  :username => 'mockuser',
  :password => 'mockpassword'
}

World do
  include Rack::Test::Methods

  def app
    @app = Rack::Builder.new do
      set :environment => :test
      set :loggining => true
      set :raise_errors => true
      set :show_exceptions => false
      run Sinatra::Application
    end
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

