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
