Given /^I enter ([A-Za-z_]+) collection$/ do |collection|
  @current_collection = collection
  @current_collection_url = "/api/%s" % collection.strip
end

Given /^I am authorized with my credentials$/ do
  #unless CONFIG[:username] == 'sbc_test_username' && CONFIG[:password] == 'sbc_test_password'
    puts 'going to authorize...'
    authorize CONFIG[:username], CONFIG[:password]
  #end
  puts 'done doing authorize test'
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

Given /^result should be valid ([A-Z]+)$/ do |format|
  if format == 'HTML'
    last_response.body.should =~ /^\<\!DOCTYPE html PUBLIC/
  else
    last_response.body.should_not =~ /^\<\!DOCTYPE html PUBLIC/
  end
end

Given /^result should contain (\d+) ([A-Za-z_]+)$/ do |count, collection|
  (xml/"/#{collection}/#{collection.gsub(/s$/, '')}").size.should == count.to_i
end

Then /^result should contain one ([A-Za-z_]+)$/ do |item|
  (xml/"/#{item}").size.should == 1
end

Given /^each ([A-Za-z_]+) should have properties set to$/ do |object, table|
  table.raw.each do |property|
    puts property[0]
    (xml/"*/#{object}/#{property[0]}").size.should_not == 0
    (xml/"*/#{object}/#{property[0]}").each do |element|
      element.text.should == property[1]
    end
  end
end

Given /^the ([A-Za-z_]+) should have properties set to$/ do |object, table|
  table.raw.each do |property|
    (xml/"/#{object}/#{property[0]}").size.should_not == 0
    (xml/"*/#{object}/#{property[0]}").each do |element|
      element.text.should == property[1]
    end
  end
end

Given /^name of these ([A-Za-z_]+) should be$/ do |collection, table|
  names = table.raw.flatten
  (xml/"/#{collection}/#{collection.gsub(/s$/, '')}/name").each do |name|
    names.delete(name.text)
  end
  names.should be_empty
end

Given /^I choose ([a-z_]+) with ([a-z_]+) ([\.0-9a-zA-Z_-]+)$/ do |collection, property, value|
  @current_collection_url += "/%s" % value if property == 'id'
end

Then /^attribute ([a-z_]+) should be set to ([0-9A-Za-z_-]+)$/ do |property, value|
  (xml/"/#{@current_collection.gsub(/s$/, '')}").first[property.to_sym].should == value
end

Then /^([a-z_]+) of this ([A-Za-z_]+) should be ([\.0-9a-zA-Z_-]+)$/ do |property, object, value|
  (xml/"/#{object}/#{property}").text.strip.should == value.strip
end