require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require_relative '../../test_helper.rb'
require_relative './common.rb'

class TestAcceptApp < Sinatra::Base
  use Rack::Accept
  use Rack::MediaType
  register Rack::RespondTo
  helpers Rack::RespondTo::Helpers
  get '/' do
    respond_to do |format|
      format.html { 'html' }
      format.xml { 'xml' }
      format.json { 'json' }
    end
  end
end

describe TestAcceptApp do

  before do
    def app; TestAcceptApp; end
  end

  it 'should return HTML when Accept header requests HTML media type' do
    header 'Accept', 'text/html'
    get '/'
    headers['Content-Type'].must_equal 'text/html'
    response_body.strip.must_equal 'html'
  end

  it 'should return HTML when Accept header is set by Firefox' do
    header 'Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    get '/'
    headers['Content-Type'].must_equal 'text/html'
    response_body.strip.must_equal 'html'
  end

  it 'should return XML when Accept header requests XML media type' do
    header 'Accept', 'application/xml'
    get '/'
    headers['Content-Type'].must_equal 'application/xml'
    response_body.strip.must_equal 'xml'
  end

  it 'should return JSON when Accept header requests JSON media type' do
    header 'Accept', 'application/json'
    get '/'
    headers['Content-Type'].must_equal 'application/json'
    response_body.strip.must_equal 'json'
  end

  it 'should return default media type when no Accept header is set' do
    get '/'
    headers['Content-Type'].must_equal 'application/xml'
  end

  it 'should return error when unknown Accept header is set' do
    header 'Accept', 'unknown/header'
    get '/'
    status.must_equal 406
  end

end
