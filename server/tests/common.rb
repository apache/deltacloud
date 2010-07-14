require 'rubygems'
require 'base64'
require 'test/unit'
require 'spec'
require 'nokogiri'
require 'json'

# Set proper environment variables for running test

ENV['RACK_ENV']     = 'test'
ENV['API_DRIVER']   = 'mock'
ENV['API_HOST']     = 'localhost'
ENV['API_PORT']     = '4040'
ENV['API_USER']     = 'mockuser'
ENV['API_PASSWORD'] = 'mockpassword'

require 'server'

set :environment => :test
set :loggining => true
set :raise_errors => false
set :show_exceptions => false

require 'rack/test'

Spec::Runner.configure do |conf|
  conf.include Rack::Test::Methods
end

module DeltacloudTestCommon

  def auth_hash(credentials)
    "Basic " + Base64.encode64("#{credentials[:user]}:#{credentials[:password]}")
  end

  def authenticate(opts={ :format => :xml })
    credentials = opts[:credentials] || { :user => ENV['API_USER'], :password => ENV['API_PASSWORD']}
    return {
      'HTTP_AUTHORIZATION' => auth_hash(credentials),
    }.merge(accept_header(opts[:format]))
  end

  def default_headers
    { 'SERVER_PORT' => ENV['API_PORT'] }
  end

  def accept_header(format=:xml)
    case format
      when :json then { 'Accept' => 'application/json' }
      when :xml then { 'Accept' => 'application/xml;q=1' }
      else { 'Accept' => 'application/xhtml+xml;text/html' }
    end.merge(default_headers)
  end

  def create_url(url, format = :xml)
    "#{url}.#{format.to_s}"
  end

  def do_request(uri, params=nil, authentication=false, opts={ :format => :xml })
    get create_url(uri, opts[:format]), params || {}, (authentication) ? authenticate(opts) : {}
  end

  def do_xml_request(uri, params=nil, authentication=false)
    get create_url(uri), params || {}, (authentication) ? authenticate : {}
    puts "[401] Authentication required to get #{uri}" if last_response.status == 401
    if last_response.status == 200
      @xml_response = false
      @xml_response = Nokogiri::XML(last_response.body) 
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

end

include DeltacloudTestCommon

