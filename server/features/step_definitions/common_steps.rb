require 'nokogiri'

When /^I want to get (HTML|XML)$/ do |format|
  case format.downcase
    when 'xml':
      header 'Accept', 'application/xml'
    when 'html':
      header 'Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
  end
end

Then /^I should see ([\w\<\>_\-]+) (.+) inside (.+)$/ do |count, model, collection|
  collection.tr!(' ', '-')
  model.tr!(' ', '-')
  if count.eql?('some')
    Nokogiri::XML(last_response.body).xpath("/#{collection}/#{model}").size.should_not == 0
  else
    Nokogiri::XML(last_response.body).xpath("/#{collection}/#{model}").size.should == replace_variables(count).to_i
  end
end

When /^I request for '(.+)' (.+)$/ do |id, model|
  get '/api/'+model.tr(' ', '_')+'s'+'/'+replace_variables(id), {}
  last_response.status.should == 200
end

Then /^I should get this (.+)$/ do |model|
  last_response.status.should == 200
  Nokogiri::XML(last_response.body).xpath("/#{model.tr(' ', '-')}").size.should == 1
end

When /^I want (.+) with '(.+)' (.+)$/ do |collection, value, parameter|
  @tested_params = []
  replace_variables(value).should_not == nil
  @tested_params << [parameter, replace_variables(value)]
end

When /^images with '(.+)' (.+)$/ do |value, parameter|
  replace_variables(value).should_not == nil
  @tested_params << [parameter, replace_variables(value)]
end

Then /^I should get only (.+) with (.+) '(.+)'$/ do |collection, parameter, value|
  params = {}
  value = replace_variables(value)
  @tested_params.collect { |param| params[:"#{param[0]}"] = param[1] }
  get '/api/'+collection, params, {}
  last_response.status.should == 200
  parameters = []
  Nokogiri::XML(last_response.body).xpath("/#{collection}/#{collection.gsub(/s$/, '')}").each do |m|
    parameters << m.xpath("#{parameter}").text
  end
  parameters.uniq.size.should == 1
  parameters.uniq.first.should == value
end

Then /^this (.+) should also have (.+) '(.+)'$/ do |collection, parameter, value|
  params = {}
  value = replace_variables(value)
  @tested_params.collect { |param| params[:"#{param[0]}"] = param[1] }
  get '/api/'+collection, params, {}
  last_response.status.should == 200
  parameters = []
  Nokogiri::XML(last_response.body).xpath("/#{collection}/#{collection.gsub(/s$/, '')}").each do |m|
    parameters << m.xpath("#{parameter}").text
  end
  parameters.uniq.size.should == 1
  parameters.uniq.first.should == value
end

Then /^I in order to see (list of|this) (.+) I need to be authorized$/ do |t, collection|
end

When /^I enter correct username and password$/ do
  authorize CONFIG[:username], CONFIG[:password]
end

Given /^I am authorized to show (.+) '(.+)'$/ do |model, id|
  authorize CONFIG[:username], CONFIG[:password]
  model.tr!(' ', '_')
  get '/api/'+model+'s/'+replace_variables(id), {}
  last_response.status.should == 200
  last_response.body.strip.should_not == 'Not authorized'
end

Then /^(.+) should include (.+) parameter$/ do |model, parameter|
  Nokogiri::XML(last_response.body).xpath("/#{model.tr(' ', '-')}/#{parameter}").first.should_not == nil
  unless ['device'].include?(parameter)
    Nokogiri::XML(last_response.body).xpath("/#{model.tr(' ', '-')}/#{parameter}").text.should_not == ""
  end
end

Given /^I am authorized to (list) (.+)$/ do |operation, collection|
  authorize CONFIG[:username], CONFIG[:password]
  get '/api/'+collection.tr(' ', '_'), {}
  last_response.body.strip.should_not == 'Not authorized'
end

When /^I follow (.+) link in entry points$/ do |entry_point|
  get '/api', {}
  href_attr = Nokogiri::XML(last_response.body).xpath("/api/link[@rel='#{entry_point.tr(' ', '_')}']").first[:href]
  href_attr.should_not == nil
  get URI.parse(href_attr).path, {}
end

Then /^each link in (.+) should point me to valid (.+)$/ do |collection, model|
  collection.tr!(' ', '_')
  model.tr!(' ', '_')
  Nokogiri::XML(last_response.body).xpath("/#{collection}/#{model}").each do |m|
    get URI.parse(m[:href]).path, {}
    last_response.status.should == 200
    Nokogiri::XML(last_response.body).root.name.should == model
    Nokogiri::XML(last_response.body).xpath("/#{model}").size.should == 1
  end
end
