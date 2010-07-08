require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'base64'
require 'nokogiri'
require 'pp'

ENV['API_DRIVER']='mock'

require 'server'

set :environment, :test

class FlavorTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_if_xml_is_valid
    get '/api/flavors.xml', {}, auth
    assert last_response.ok?
    document = Nokogiri::XML(last_response.body)
    assert_equal '1.0', document.version
  end

  def test_index_operation
    get '/api/flavors.xml', {}, auth
    original = Nokogiri::XML(xml_file_content('flavors'))
    responded = Nokogiri::XML(last_response.body)
    assert_equal original.to_s, responded.to_s
  end

  def test_index_filter_architecture
    get '/api/flavors.xml', { :architecture => 'x86_64'}, auth
    original = Nokogiri::XML(xml_file_content('flavors-x86_64'))
    responded = Nokogiri::XML(last_response.body)
    assert_equal original.to_s, responded.to_s
    original = Nokogiri::XML(xml_file_content('flavors-unknown-testing'))
    get '/api/flavors.xml', { :architecture => 'unknown-testing'}, auth
    assert_equal original.to_s, responded.to_s
  end

  def test_show_operation
    get '/api/flavors.xml', {}, auth
    url = Nokogiri::XML(xml_file_content('flavors')).xpath('/flavors/flavor[1]').attr('href').to_s
    get "#{url}.xml", {}, auth
    original = Nokogiri::XML(xml_file_content('flavors-m1-small'))
    responded = Nokogiri::XML(last_response.body)
    assert_equal original.to_s, responded.to_s
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
