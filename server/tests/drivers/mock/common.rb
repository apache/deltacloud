unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

API_ROOT_URL = "/api" unless defined?(API_ROOT_URL)
API_VERSION = "1.0.0" unless defined?(API_VERSION)
ENV['API_DRIVER'] ||= 'mock'

ENV['API_USERNAME'] ||= 'mockuser'
ENV['API_PASSWORD'] ||= 'mockpassword'

require_relative '../../../lib/deltacloud/server.rb'

require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'
require 'json'

require 'pp'

module Deltacloud
  module Test
    include Rack::Test::Methods

    def included?(sub)
      sub.class_eval do
        before do
          header 'Accept', 'application/xml'
        end
      end
    end

    def xml_response
      Nokogiri::XML(last_response.body)
    end

    def auth_as_mock
      authorize ENV['API_USERNAME'], ENV['API_PASSWORD']
    end

    def collection_url(collection)
      [API_ROOT_URL, collection.to_s].join('/')
    end

    def app
      Rack::Builder.new {
        map '/' do
          use Rack::Static, :urls => ["/stylesheets", "/javascripts"], :root => "public"
          run Rack::Cascade.new([Deltacloud::API])
        end
      }
    end
  end
end
