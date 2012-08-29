require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require_relative '../../test_helper.rb'
require_relative './common.rb'

class TestEtagApp < Sinatra::Base
  use Rack::ETag
  get '/' do
    params[:test]
  end
end

describe TestEtagApp do

  before do
    def app; TestEtagApp; end
  end

  it 'add the ETag header to all responses' do
    get '/?test=1'
    status.must_equal 200
    response_body.wont_be_empty
    headers['ETag'].wont_be_empty
    headers['ETag'].must_equal 'c4ca4238a0b923820dcc509a6f75849b'
    get '/?test=2'
    headers['ETag'].must_equal 'c81e728d9d4c2f636f067f89cc14862c'
  end

end
