require_relative File.join('..', '..', '..', 'lib', 'deltacloud_rack.rb')
require_relative '../../test_helper.rb'

# Setup CIMI::API Sinatra instance
#
Deltacloud::configure(:cimi) do |server|
  server.root_url '/cimi'
  server.version '1.0.0'
  server.klass 'CIMI::API'
  server.default_driver :mock
  server.logger Rack::DeltacloudLogger.setup(ENV['API_LOG'], ENV['API_VERBOSE'])
end

Deltacloud[:cimi].require!
Deltacloud[:cimi].default_frontend!

def formats; [ 'application/xml', 'application/json' ]; end

def model_class
  resource = nil
  resp = last_response
  ct = resp.content_type
  if ct == "application/json"
    json = JSON::parse(last_response.body)
    json["resourceURI"].wont_be_nil
    resource = json["resourceURI"].split("/").last
  elsif ct == "application/xml"
    xml = Nokogiri::XML(last_response.body)
    if xml.root.name == "Collection"
      resource = xml.root["resourceURI"].split("/").last
    else
      resource = xml.root.name
    end
  elsif resp.body.nil? || resp.body.size == 0
    raise "Can not construct model from empty body"
  else
    raise "Unexpected content type #{resp.content_type}"
  end
  CIMI::Model::const_get(resource)
end

def model
  model_class.parse(last_response.body, last_response.content_type)
end
