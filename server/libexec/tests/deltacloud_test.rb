require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'base64'
require 'nokogiri'
require 'pp'
require 'sinatra'

ENV['API_DRIVER']='mock'
ENV['API_HOST']='localhost'

require 'server'

set :environment => :test

module DeltacloudTest
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_if_response_is_valid
      get '/api/'+@collection+'.xml', @params, rack_headers
      assert last_response.ok?
    end

    def test_if_http_status_is_correct_with_wrong_credentials
      return if ['flavors', 'realms'].include?(@collection)
      wrong_header = rack_headers
      wrong_header['HTTP_AUTHORIZATION'] = authorization('wronguser', 'wrongpassword')
      get '/api/'+@collection+'.xml', @params, wrong_header
      assert_equal 403, last_response.status
    end

    def test_if_index_operation_proper_root_element
      get '/api/'+@collection+'.xml', @params, rack_headers
      doc = Nokogiri::XML.parse(last_response.body)
      assert_equal @collection.gsub('_', '-'), doc.root.name
    end

    def test_html_response
      get '/api/'+@collection+'.html', @params, rack_headers
      doc = Nokogiri::HTML.parse(last_response.body)
      assert_equal 'html', doc.root.name
    end

    def authorization(username, password)
      "Basic " + Base64.encode64("#{username}:#{password}")
    end

    def rack_headers
      return {
        'HTTP_AUTHORIZATION' => authorization('mockuser', 'mockpassword'),
        'SERVER_PORT' => '4040',
        'Accept' => 'application/xml;q=1'
      }
    end

end
