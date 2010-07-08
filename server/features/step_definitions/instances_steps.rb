Then /^instance state should be (.+)$/ do |state|
  Nokogiri::XML(last_response.body).xpath("/instance/state").first.text.should == state
end

When /^instance state is (.+)$/ do |state|
  Nokogiri::XML(last_response.body).xpath("/instance/state").first.text.should == state
end

Then /^instance should have one (public|private) address$/ do |type|
  adr = Nokogiri::XML(last_response.body).xpath("/instance/#{type}-addresses/address").first
  adr.text.to_s.should_not == nil
  adr.text.to_s.should_not == ''
end

Then /^instance should include link to '(.+)' action$/ do |action|
  links = Nokogiri::XML(last_response.body).xpath("/instance/actions/link")
  actions = []
  links.each do |link|
    actions << link[:rel]
  end
  actions.include?(action).should == true
end

When /^I want to get details about instance (.+)$/ do |model|
end

Then /^I could follow (image|realm|flavor) href attribute$/ do |model|
  m = Nokogiri::XML(last_response.body).xpath("/instance/#{model}").first
  model_url = URI.parse(m[:href]).path
  get model_url, {}
end

Then /^this attribute should point me to valid (image|realm|flavor)$/ do |model|
  Nokogiri::XML(last_response.body).xpath("/#{model}").first.name.should == model
end

When /^I want to (.+) this instance$/ do |action|
end

Given /^I am authorized to create instance$/ do
  last_response.body.strip.should_not == 'Not authorized'
end

Then /^I could follow (.+) action in actions$/ do |action|
  link = Nokogiri::XML(last_response.body).xpath("/instance/actions/link[@rel='#{action}']").first
  post URI.parse(link[:href]).path, {}
end

Then /^this instance state should be '(.+)'$/ do |state|
  Nokogiri::XML(last_response.body).xpath("/instance/state").first.text.should == state
end

When /^I request create new instance with:$/ do |table|
  params = {}
  table.raw.map { |a,b| params[:"#{a}"] = replace_variables(b) }
  post '/api/instances.xml', params
  @instance_id = Nokogiri::XML(last_response.body).xpath("/instance/id").first.text
  @instance_id.should_not == nil
  CONFIG[$DRIVER][:instance_1_id] = @instance_id unless CONFIG[$DRIVER][:instance_1_id]
end

Then /^I should request this instance$/ do
  get URI.encode('/api/instances/'+@instance_id), {}
  Nokogiri::XML(last_response.body).xpath("/instance").first.should_not == nil
end

Then /^this instance should be '(.+)'$/ do |state|
  get URI.encode('/api/instances/'+@instance_id), {}
  Nokogiri::XML(last_response.body).xpath("/instance/state").first.text.should == state
end

Then /^this instance should have name '(.+)'$/ do |name|
  get URI.encode('/api/instances/'+@instance_id), {}
  Nokogiri::XML(last_response.body).xpath("/instance/name").first.text.should == replace_variables(name)
end

Then /^this instance should be image '(.+)'$/ do |image|
  get URI.encode('/api/instances/'+@instance_id), {}
  get URI.parse(Nokogiri::XML(last_response.body).xpath("/instance/image").first[:href]).path, {}
  Nokogiri::XML(last_response.body).xpath("/image/id").first.text.should == replace_variables(image)
end

Then /^this instance should have realm  '(.+)'$/ do |realm|
  get URI.encode('/api/instances/'+@instance_id), {}
  get URI.parse(Nokogiri::XML(last_response.body).xpath("/instance/realm").first[:href]).path, {}
  Nokogiri::XML(last_response.body).xpath("/realm/id").first.text.should == replace_variables(realm)
end
