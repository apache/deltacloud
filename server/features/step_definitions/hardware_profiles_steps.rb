Then /^it should have a (\w+) attribute$/ do |name|
  attr = output_xml.xpath('/hardware-profile').first[name]
  attr.should_not be_nil
end

Then /^it should have a (\w+) property '(.+)'$/ do |kind, name|
  props = output_xml.xpath("/hardware-profile/property[@name = '#{name}']")
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

