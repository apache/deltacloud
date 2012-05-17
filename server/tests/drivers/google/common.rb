ENV['API_DRIVER']   = "google"
ENV['API_USER']     = 'GOOGK7JXLS6UEYS6AYVO'
ENV['API_PASSWORD'] = 'QjxUunLgszKhBGn/LISQajGR82CfwvraxA9lqnkg'

load File.join(File.dirname(__FILE__), '..', '..', 'common.rb')
require 'vcr'

DeltacloudTestCommon::record!

VCR.config do |c|
  c.cassette_library_dir = "#{File.dirname(__FILE__)}/fixtures/"
  c.stub_with :excon
  c.default_cassette_options = { :record => :new_episodes}
end

#monkey patch fix for VCR normalisation code:
#see https://github.com/myronmarston/vcr/issues/4
#when body is a tempfile, like when creating new blob
#this method of normalisation fails and excon throws errors
#(Excon::Errors::SocketError:can't convert Tempfile into String)
#
#RELEVANT: https://github.com/myronmarston/vcr/issues/101
#(will need revisiting when vcr 2 comes along)

module VCR
  module Normalizers
    module Body

    private
    def normalize_body
     self.body = case body
          when nil, ''; nil
          else
            String.new(body) unless body.is_a?(Tempfile)
        end
      end
    end
  end
end

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
      [Deltacloud[:root_url], collection.to_s].join('/')
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
