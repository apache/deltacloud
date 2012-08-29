require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require_relative '../../test_helper.rb'
require_relative './common.rb'

class TestDateApp < Sinatra::Base
  use Rack::Date
  get '/' do
    'OK'
  end
end

describe TestDateApp do

  before do
    def app; TestDateApp; end
  end

  it 'add the Date header to all responses' do
    get '/'
    status.must_equal 200
    response_body.wont_be_empty
    headers['Date'].wont_be_empty
    Time.parse(headers['Date']).must_be_instance_of Time
  end

end
