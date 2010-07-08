require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'base64'
require 'nokogiri'
require 'pp'

ENV['API_DRIVER']='mock'

require 'server'

set :environment, :test

class RealmTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_if_xml_is_valid
    get '/api/realms.xml', {}, auth
    assert last_response.ok?
    document = Nokogiri::XML(last_response.body)
    assert_equal '1.0', document.version
  end

  def test_index_operation
    get '/api/realms.xml', {}, auth
    original = Nokogiri::XML(xml_file_content('realms'))
    responded = Nokogiri::XML(last_response.body)
    assert_equal original.to_s, responded.to_s
  end

# TODO: Does Realms have 'architecture' ?
=begin
  def test_index_filter_architecture
    get '/api/realms.xml', { :architecture => 'x86_64'}, auth
    original = Nokogiri::XML(xml_file_content('realms-x86_64'))
    responded = Nokogiri::XML(last_response.body)
    assert_equal original.to_s, responded.to_s
    original = Nokogiri::XML(xml_file_content('realms-unknown-testing'))
    get '/api/realms.xml', { :architecture => 'unknown-testing'}, auth
    assert_equal original.to_s, responded.to_s
  end
=end

  def test_show_operation
    get '/api/realms.xml', {}, auth
    url = Nokogiri::XML(xml_file_content('realms')).xpath('/realms/realm[1]').attr('href').to_s
    get "#{url}.xml", {}, auth
    original = Nokogiri::XML(xml_file_content('realms-us'))
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
