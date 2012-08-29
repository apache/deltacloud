require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require_relative '../../test_helper.rb'
require_relative './common.rb'

class TestDriverApp < Sinatra::Base
  use Rack::DriverSelect
  get '/' do
    headers 'Driver' => Thread.current[:driver]
    headers 'Provider' => Thread.current[:provider]
    'OK'
  end
end

describe TestDriverApp do

  before do
    def app; TestDriverApp; end
  end

  it 'should set the driver correctly when using X-Deltacloud-Driver request header' do
    header 'X-Deltacloud-Driver', 'ec2'
    get '/'
    headers['Driver'].wont_be_empty
    headers['Driver'].must_equal 'ec2'
    headers['Provider'].must_be_nil
    header 'X-Deltacloud-Driver', 'test'
    get '/'
    headers['Driver'].wont_be_empty
    headers['Driver'].must_equal 'test'
    headers['Provider'].must_be_nil
  end

  it 'should set the provider correctly when using X-Deltacloud-Provider header' do
    header 'X-Deltacloud-Provider', 'default'
    get '/'
    headers['Provider'].wont_be_empty
    headers['Provider'].must_equal 'default'
    header 'X-Deltacloud-Provider', 'http://someurl.com:8774/api;1234-1234-1235-1235'
    get '/'
    headers['Provider'].wont_be_nil
    headers['Provider'].must_equal 'http://someurl.com:8774/api;1234-1234-1235-1235'
  end

  it 'should set both provider and driver' do
    header 'X-Deltacloud-Provider', 'default'
    header 'X-Deltacloud-Driver', 'test'
    get '/'
    headers['Provider'].must_equal 'default'
    headers['Driver'].must_equal 'test'
  end

end
