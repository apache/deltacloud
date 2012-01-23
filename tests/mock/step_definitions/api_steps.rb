World(Rack::Test::Methods)

Given /^URI ([\w\/\-_]+) exists$/ do |uri|
  get uri
  last_response.status.should_not == 404
  last_response.status.should_not == 500
  @uri = uri
end

Given /^URI ([\w\/\-_]+) exists in (.+) format$/ do |uri, format|
  @no_header = true
  case format.downcase
    when 'xml':
      header 'Accept', 'application/xml;q=9'
    when 'json'
      header 'Accept', 'application/json;q=9'
    when 'html'
      header 'Accept', 'application/xml+xhtml;q=9'
  end
  @uri = uri
  get uri, {}
  last_response.status.should_not == 404
  last_response.status.should_not == 500
end

Given /^authentification is not required for this URI$/ do
  last_response.status.should_not == 401
end

When /^client access this URI$/ do
  get @uri, {}
  last_response.status.should_not == 404
end

Then /^client should get root element '(.+)'$/ do |element|
  @last_element = output_xml.xpath('/'+element).first
  @last_element.should_not be_nil
  @last_element.name.should == element
end

Then /^this element should have attribute '(.+)' with value '(.+)'$/ do |atr, val|
  @last_element[atr.to_sym].should == val
end

Then /^client should get list of valid entry points:$/ do |table|
  @entry_points = table.raw.flatten.sort
  links = []
  output_xml.xpath('/api/link').each do |entry_point|
    links << entry_point['rel']
  end
  @entry_points.should == links.sort
end

Then /^this URI should be available in (.+) format$/ do |formats|
  @no_header = true
  formats.split(',').each do |format|
    case format.downcase
      when 'xml':
        header 'Accept', 'application/xml;q=9'
      when 'json'
        header 'Accept', 'application/json;q=9'
      when 'html'
        header 'Accept', 'application/xml+xhtml;q=9'
    end
    get @uri, {}
    last_response.status.should == 200
  end
  @no_header = false
end

Then /^each (\w+) should have '(.+)' attribute with valid (.+)$/ do |el, attr, t|
  case el
    when 'link':
      path = '/api/link'
    when 'image':
      path = '/images/image'
    when 'instance':
      path = '/instances/instance'
    when 'key':
      path = '/keys/key'
    when 'realm':
      path = '/realms/realm'
  end
  output_xml.xpath(path).each do |entry_point|
    @entry_points.include?(entry_point[attr]).should == true if t=='name'
    if t=='URL'
      entry_point[:href].should_not be_nil
    end
  end
  @last_attribute = attr
end

Then /^each ([\w\-]+) should have '(.+)' attribute set to '(.+)'$/ do |el, attr, v|
  case el
    when 'image':
      path = "/image/images"
    when 'hardware_profile':
      path = "/hardware_profiles/hardware_profile"
    when 'instance':
      path = "/instances/instance"
  end
  output_xml.xpath(path).each do |element|
    element[attr].should == v
  end
end

Then /^each ([\w\-]+) should have '(.+)' element set to '(.+)'$/ do |el, child, v|
  case el
    when 'image':
      path = "/images/image"
    when 'hardware_profile':
      path = "/hardware_profiles/hardware_profile"
    when 'instance':
      path = "/instances/instance"
  end
  output_xml.xpath(path).each do |element|
     element.xpath(child).should_not be_nil
     element.xpath(child).first.content.should == v
  end
end

Then /^each ([\w\-]+) should have '(.+)' property set to '(.+)'$/ do |el, property, v|
  case el
    when 'hardware_profile':
      path = "/hardware_profiles/hardware_profile"
  end
  output_xml.xpath(path).each do |element|
    property_elm=element.xpath("property[@name=\"#{property}\"]")
    next unless property_elm.first
    property_elm.should_not be_nil
    property_elm.first["value"].should == v
  end
end

When /^client follow this attribute$/ do
  output_xml.xpath('/api/link').each do |entry_point|
    get entry_point[@last_attribute], {}
  end
end

Then /^client should get a valid response$/ do
  last_response.status.should_not == 500
end

Then /^client should get list of features inside '(.+)':$/ do |element,table|
  features = table.raw.flatten.sort
  instance_features = []
  output_xml.xpath('/api/link[@rel="'+element+'"]/feature').each do |feature|
    instance_features << feature[:name]
  end
  features.should == instance_features.sort
end
