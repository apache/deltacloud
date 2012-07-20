Given /^I enter ([A-Za-z_]+) collection$/ do |collection|
  @current_collection = collection
  @current_collection_url = "/api/%s" % collection.strip
end

Given /^I am authorized with my credentials$/ do
  authorize CONFIG[:username], CONFIG[:password]
end

When /^I request ([A-Z]+) response$/ do |format|
  if format == 'HTML'
    header 'Accept', 'text/html'
  end
  if format == 'XML'
    header 'Accept', 'application/xml'
  end
  get @current_collection_url, {}
  last_response.status == 200
end

Then /^result should be valid ([A-Z]+)$/ do |format|
  if format == 'HTML'
    last_response.body.should =~ /^\<\!DOCTYPE html PUBLIC/
  else
    last_response.body.should_not =~ /^\<\!DOCTYPE html PUBLIC/
  end
end

Then /^result should contain (\d+) ([A-Za-z_]+)$/ do |count, collection|
  (xml/"/#{collection}/#{collection.gsub(/s$/, '')}").size.should == count.to_i
end

Then /^name of these ([A-Za-z_]+) should be$/ do |collection, table|
  names = table.raw.flatten
  (xml/"/#{collection}/#{collection.gsub(/s$/, '')}/name").each do |name|
    names.delete(name.text)
  end
  names.should be_empty
end

Then /^([a-z]+) properties should be$/ do |type, table|
  properties = table.raw.flatten
  (xml/"hardware_profiles/hardware_profile/property[@kind='#{type}']").each do |name|
    properties.delete(name[:name])
  end
  properties.should be_empty
end

Given /^I choose ([a-z_]+) with ([a-z_]+) ([0-9a-zA-Z_-]+)$/ do |collection, property, value|
  @current_collection_url += "/%s" % value if property == 'id'
end

Then /^result should contain one ([A-Za-z_]+)$/ do |item|
  (xml/"/#{item}").size.should == 1
end

Then /^([a-z_]+) of this ([A-Za-z_]+) should be ([A-Za-z_]+)$/ do |property, object, value|
  (xml/"/#{object}/#{property}").text.strip.should == value.strip
end

Then /^range properties should have default, first and last values:$/ do |table|
  table.raw.each do |property|
    (xml/"/hardware_profile/property[@name='#{property[0]}']").first.should_not be_nil
    (xml/"/hardware_profile/property[@name='#{property[0]}']").first[:value].should_not be_nil
    (xml/"/hardware_profile/property[@name='#{property[0]}']").first[:value].should == property[1]
    (xml/"/hardware_profile/property[@name='#{property[0]}']/range").first[:first].should_not be_nil
    (xml/"/hardware_profile/property[@name='#{property[0]}']/range").first[:first].should == property[2]
    (xml/"/hardware_profile/property[@name='#{property[0]}']/range").first[:last].should_not be_nil
    (xml/"/hardware_profile/property[@name='#{property[0]}']/range").first[:last].should == property[3]
  end
end

Then /^range properties should have param for instance create operation$/ do
  (xml/"hardware_profile/*/param").length.should > 0
  (xml/"/hardware_profile/*/param").each do |param|
    param[:href].should_not be_nil
    param[:method].should == "post"
    param[:name].should_not be_nil
    param[:operation].should == "create"
  end
end

