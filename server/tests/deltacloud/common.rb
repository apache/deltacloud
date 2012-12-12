require_relative '../test_helper.rb'
require_relative File.join('..', '..', 'lib', 'deltacloud_rack.rb')

# Setup Deltacloud::API Sinatra instance

Deltacloud::configure do |server|
  server.root_url '/api'
  server.version Deltacloud::API_VERSION
  server.klass 'Deltacloud::API'
  server.logger Rack::DeltacloudLogger.setup(ENV['API_LOG'], ENV['API_VERBOSE'])
  server.default_driver :mock
end

Deltacloud.require_frontend!

def check_json_serialization_for(model, sample_id)
  header 'Accept', 'application/json'
  get root_url + "/#{model.to_s.pluralize}"
  status.must_equal 200
  json[model.to_s.pluralize].wont_be_empty
  get root_url + "/#{model.to_s.pluralize}/#{sample_id}"
  status.must_equal 200
  json[model.to_s].wont_be_empty
  klass = self.class.const_get(model.to_s.camelize)
  klass.attributes.each do |attr|
    attr = attr.to_s.gsub(/_id$/,'') if attr.to_s =~ /_id$/
    json[model.to_s].keys.must_include attr.to_s
  end
end
