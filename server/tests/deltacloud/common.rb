require_relative '../test_helper.rb'

Deltacloud.require_frontend! :deltacloud

def check_json_serialization_for(model, sample_id, optional_attrs=[])
  header 'Accept', 'application/json'
  get root_url + "/#{model.to_s.pluralize}"
  status.must_equal 200
  json[model.to_s.pluralize].wont_be_empty
  get root_url + "/#{model.to_s.pluralize}/#{sample_id}"
  status.must_equal 200
  json[model.to_s].wont_be_empty
  klass = Deltacloud.const_get(model.to_s.camelize)
  klass.attributes.each do |attr|
    attr = attr.to_s.gsub(/_id$/,'') if attr.to_s =~ /_id$/
    json[model.to_s].keys.must_include attr.to_s unless optional_attrs.include? attr
  end
end
