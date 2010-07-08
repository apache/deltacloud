require 'nokogiri'

When /^I want to get (HTML|XML)$/ do |format|
  case format.downcase
    when 'xml':
      header 'Accept', 'application/xml'
  end
end

When /^I request (.+) operation for (.+) collection$/ do |operation, collection|
  operation = '/'+operation
  operation = operation.eql?('/index') ? '' : operation
  collection.tr!(' ', '_')
  get '/api/'+collection+operation, {}
end

Then /^I should see ([\w\<\>_\-]+) (.+) inside (.+)$/ do |count, model, collection|
  collection.tr!(' ', '-')
  model.tr!(' ', '-')
  if count.eql?('some')
    Nokogiri::XML(last_response.body).xpath("/#{collection}/#{model}").size.should_not == 0
  else
    count = replace_variables(count)
    Nokogiri::XML(last_response.body).xpath("/#{collection}/#{model}").size.should == count.to_i
  end
end

When /^I request for '(.+)' (.+)$/ do |id, model|
  model.tr!(' ', '_')
  get '/api/'+model+'s'+'/'+replace_variables(id), {}
end

Then /^I should get this (.+)$/ do |model|
  model.tr!(' ', '-')
  Nokogiri::XML(last_response.body).xpath("/#{model}").size.should == 1
end

When /^I want (.+) with '(.+)' (.+)$/ do |collection, value, parameter|
  @params = []
  @params << [parameter, replace_variables(value)]
end

When /^images with '(.+)' (.+)$/ do |value, parameter|
  @params << [parameter, replace_variables(value)]
end

Then /^I should get only (.+) with (.+) '(.+)'$/ do |collection, parameter, value|
  params = {}
  value = replace_variables(value)
  @params.collect { |param| params[:"#{param[0]}"] = param[1] }
  get '/api/'+collection, params, {}
  p = []
  Nokogiri::XML(last_response.body).xpath("/#{collection}/#{collection.gsub(/s$/, '')}").each do |m|
    p << m.xpath("#{parameter}").text
  end
  p.uniq!
  p.size.should == 1
  p.first.should == value
end

Then /^this (.+) should also have (.+) '(.+)'$/ do |collection, parameter, value|
  params = {}
  value = replace_variables(value)
  @params.collect { |param| params[:"#{param[0]}"] = param[1] }
  get '/api/'+collection, params, {}
  p = []
  Nokogiri::XML(last_response.body).xpath("/#{collection}/#{collection.gsub(/s$/, '')}").each do |m|
    p << m.xpath("#{parameter}").text
  end
  p.uniq!
  p.size.should == 1
  p.first.should == value
end

Then /^I in order to see (list of|this) (.+) I need to be authorized$/ do |t, collection|
  last_response.body.strip.should == 'Not authorized'
end

When /^I enter correct username and password$/ do
  authorize 'mockuser', 'mockpassword'
end

Given /^I am authorized to show (.+) '(.+)'$/ do |model, id|
   model.tr!(' ', '_')
   authorize 'mockuser', 'mockpassword'
   get '/api/'+model+'s/'+model+'/'+replace_variables(id), {}
   last_response.body.strip.should_not == 'Not authorized'
end

Then /^(.+) should contain (.+) parameter$/ do |model, parameter|
  model.tr!(' ', '-')
  Nokogiri::XML(last_response.body).xpath("/#{model}/#{parameter}").first.should_not == nil
  Nokogiri::XML(last_response.body).xpath("/#{model}/#{parameter}").first.text.should_not == ''
end

Given /^I am authorized to (list) (.+)$/ do |operation, collection|
  authorize 'mockuser', 'mockpassword'
  collection.tr!(' ', '_')
  get '/api/'+collection, {}
  last_response.body.strip.should_not == 'Not authorized'
end
