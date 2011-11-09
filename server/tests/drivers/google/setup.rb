ENV['API_DRIVER']   = "google"
ENV['API_USER']     = 'GOOGK7JXLS6UEYS6AYVO'
ENV['API_PASSWORD'] = 'QjxUunLgszKhBGn/LISQajGR82CfwvraxA9lqnkg'

require 'vcr'

DeltacloudTestCommon::record!

VCR.config do |c|
  c.cassette_library_dir = "#{File.dirname(__FILE__)}/fixtures/"
  c.stub_with :excon
  c.default_cassette_options = { :record => :new_episodes}
end
