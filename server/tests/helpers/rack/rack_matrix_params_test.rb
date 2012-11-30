require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require_relative '../../test_helper.rb'
require_relative './common.rb'

class TestMatrixApp < Sinatra::Base
  use Rack::MatrixParams
  get '/' do
    params.to_json
  end
  get '/test' do
    params.to_json
  end
  get '/test/books' do
    params.to_json
  end
end

describe TestMatrixApp do

  before do
    def app; TestMatrixApp; end
  end

  it 'should set matrix param for entrypoint' do
    get '/;test=1'
    status.must_equal 200
    json['test'].must_equal '1'
  end

  it 'should set multiple matrix params for entrypoint' do
    get '/;test=1;foo=bar'
    status.must_equal 200
    json['test'].must_equal '1'
    json['foo'].must_equal 'bar'
  end

  it 'should set matrix param for first part of URI' do
    get '/test;foo=bar'
    status.must_equal 200
    json['test']['foo'].must_equal 'bar'
  end

  it 'should set multiple matrix params for first part of URI' do
    get '/test;foo=bar;test1=blah'
    status.must_equal 200
    json['test']['foo'].must_equal 'bar'
    json['test']['test1'].must_equal 'blah'
  end

  it 'should set matrix params for the last part of URI' do
    get '/test/books;foo=bar'
    status.must_equal 200
    json['books']['foo'].must_equal 'bar'
  end

  it 'should set matrix params for multiple parts of URI' do
    get '/test;test=1/books;foo=bar'
    status.must_equal 200
    json['books']['foo'].must_equal 'bar'
    json['test']['test'].must_equal '1'
  end

  it 'should handle matrix params with wrong syntax' do
    get '/test;;;/books;foo=bar'
    json['books']['foo'].must_equal 'bar'
    json['test'].must_be_nil
  end

end
