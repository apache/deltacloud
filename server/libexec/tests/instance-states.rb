require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'base64'
require 'nokogiri'
require 'pp'

ENV['API_DRIVER']='mock'

require 'server'

set :environment, :test

class InstanceStatesTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_if_xml_is_valid
    get '/api/instance_states.xml', {}, auth
    assert last_response.ok?
    document = Nokogiri::XML(last_response.body)
    assert_equal '1.0', document.version
  end

  def test_index_operation
    get '/api/instance_states.xml', {}, auth
    assert last_response.ok?
    original = Nokogiri::XML(xml_file_content('instance-states'))
    document = Nokogiri::XML(last_response.body)
    assert_equal original.to_s, document.to_s
  end

  private

  def xml_file_content(name)
    out = ""
    File.open("tests/xmls/#{name}.xml", 'r') do |f|
      while (line = f.gets)
        out += line
      end
    end
    return out
  end

  def auth
    auth_string = "Basic " + Base64.encode64("mockuser:mockpassword")
    @auth = { 'HTTP_AUTHORIZATION' => auth_string }
  end

end
