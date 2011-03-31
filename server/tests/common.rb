$:.unshift File.join(File.dirname(__FILE__), '..')

require 'rubygems'
require 'yaml'
require 'base64'
require 'test/unit'
require 'spec'
require 'nokogiri'
require 'json'

# Set proper environment variables for running test

ENV['RACK_ENV']     = 'test'
ENV['API_HOST']     = 'localhost'
ENV['API_PORT']     = '4040'

require 'server'

configure :test do
  set :loggining, true
  set :clean_trace, true
  set :dump_errors, true
  set :raise_errors, true
  set :show_exceptions, false
end

require 'rack/test'

Spec::Runner.configure do |conf|
  conf.include Rack::Test::Methods
end

module DeltacloudTestCommon

  def auth_hash(credentials)
    "Basic " + Base64.encode64("#{credentials[:user]}:#{credentials[:password]}")
  end

  def authenticate(opts={})
    credentials = opts[:credentials] || { :user => ENV['API_USER'], :password => ENV['API_PASSWORD']}
    return {
      'HTTP_AUTHORIZATION' => auth_hash(credentials),
    }
  end

  def default_headers
    { 'SERVER_PORT' => ENV['API_PORT'] }
  end

  def accept_header(format=:xml)
    case format
      when :json then 'application/json;q=0.9'
      when :html then 'text/html;q=0.9'
      when :xml then 'application/xml;q=0.9'
      else 'application/xml;q=0.9'
    end
  end

  def create_url(url, format = :xml)
    "#{url}"
  end

  require 'digest/sha1'

  def do_request(uri, params=nil, authentication=false, opts={ :format => :xml })
    header 'Accept', accept_header(opts[:format])
    VCR.use_cassette(Digest::SHA1.hexdigest("#{uri}-#{params}-#{authentication}")) do
      get create_url(uri), params || {}, (authentication) ? authenticate(opts) : {}
    end
  end

  def do_xml_request(uri, params=nil, authentication=false)
    header 'Accept', accept_header(:xml)
    VCR.use_cassette(Digest::SHA1.hexdigest("#{uri}-#{params}-#{(authentication) ? authenticate : ''}")) do
      get create_url(uri), params || {}, (authentication) ? authenticate : {}
    end
    if last_response.status == 200
      @xml_response = false
      @xml_response = Nokogiri::XML(last_response.body)
    end
  end

  def do_post(uri, params, authentication)
    VCR.use_cassette(Digest::SHA1.hexdigest("#{uri}-#{params}-#{(authentication) ? authenticate : ''}")) do
      post uri, params, authentication ? authenticate : nil
    end
  end

  def require_authentication?(uri)
    get uri, {}
    true if last_response.status.eql?(401)
  end

  def last_xml_response
    @xml_response || Nokogiri::XML::Document.new
  end

  def add_created_instance(id)
    $created_instances ||= []
    $created_instances << id
  end

  def with_provider(new_provider, &block)
    old_provider = ENV["API_PROVIDER"]
    begin
      ENV["API_PROVIDER"] = new_provider
      yield
    ensure
      ENV["API_PROVIDER"] = old_provider
    end
  end
end

include DeltacloudTestCommon
