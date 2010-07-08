Then /^it should have a (\w+) attribute$/ do |name|
  attr = Nokogiri::XML(last_response.body).xpath('/hardware-profile').first[name]
  attr.should_not be_nil
  if (name == 'href')
    attr.should == "http://example.org/api/hardware_profiles/#{CONFIG[:hardware_profile_id]}"
  end
end

Then /^it should have a (\w+) property '(.+)'$/ do |kind, name|
  props = Nokogiri::XML(last_response.body).xpath("/hardware-profile/property[@name = '#{name}']")
  props.size.should == 1
  prop = props.first
  prop['kind'].should == kind
  prop['unit'].should_not be_nil
  if kind == 'range'
    ranges = prop.xpath('range')
    ranges.size.should == 1
    range = ranges.first
    range['first'].should_not be_nil
    range['last'].should_not be_nil
  end
  if kind == 'enum'
    enums = prop.xpath('enum')
    enums.size.should == 1
    enums.first.xpath('entry').size.should_not == 0
  end
end

Then /^the returned hardware profiles should have (.+) '(.+)'$/ do |parameter, value|
  params = {}
  value = replace_variables(value)
  @tested_params.collect { |param| params[:"#{param[0]}"] = param[1] }
  get '/api/hardware_profiles', params, {}
  last_response.status.should == 200
  parameters = []
  Nokogiri::XML(last_response.body).xpath("/hardware-profiles/hardware-profile/property[@name = '#{parameter}']").each do |elt|
      parameters << elt['value']
  end
  parameters.uniq.size.should == 1
  parameters.uniq.first.should == value
end
