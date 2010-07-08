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
  last_response.status.should == 200
end

Then /^this attribute should point me to valid (image|realm|flavor)$/ do |model|
  attribute = Nokogiri::XML(last_response.body).xpath("/#{model}").first
  attribute.should_not == nil
  attribute.name.should == model
end

When /^I want to (.+) this instance$/ do |action|
end

Given /^I am authorized to create instance$/ do
  last_response.status.should_not == 401
end

Then /^I could follow (.+) action in actions$/ do |action|
  link = Nokogiri::XML(last_response.body).xpath("/instance/actions/link[@rel='#{action}']").first
  link.should_not == nil
  post URI.parse(link[:href]).path, {}
  last_response.status.should == 200
end

Then /^this instance state should be '(\w+)'$/ do |state|
  Nokogiri::XML(last_response.body).xpath("/instance/state").first.text.should == state
end

Then /^this instance state should be '(\w+)' or '(\w+)'$/ do |state, state_2|
  instance_state = Nokogiri::XML(last_response.body).xpath("/instance/state").first
  instance_state.should_not == nil
  [state, state_2].include?(instance_state.text).should == true
end

When /^I request create new instance with:$/ do |table|
  params = {}
  table.raw.map { |a,b| params[:"#{a}"] = replace_variables(b) }
  post '/api/instances', params
  @instance_id = Nokogiri::XML(last_response.body).xpath("/instance/id").first.text
  @instance_id.should_not == nil
  CONFIG[:instance_1_id] = @instance_id unless CONFIG[:instance_1_id]
end

Then /^I should request this instance$/ do
  get URI.encode('/api/instances/'+@instance_id), {}
  last_response.status.should == 200
  Nokogiri::XML(last_response.body).xpath("/instance").first.should_not == nil
end

Then /^this instance should be '(RUNNING|PENDING|STOPPED)'$/ do |state|
  get URI.encode('/api/instances/'+@instance_id), {}
  last_response.status.should == 200
  Nokogiri::XML(last_response.body).xpath("/instance/state").first.text.should == state
end

Then /^this instance should be '(RUNNING|PENDING|STOPPED)' or '(RUNNING|PENDING|STOPPED)'$/ do |state, second_state|
  get URI.encode('/api/instances/'+@instance_id), {}
  last_response.status.should == 200
  [state, second_state].include?(Nokogiri::XML(last_response.body).xpath("/instance/state").first.text).should == true
end

Then /^this instance should have name '(.+)'$/ do |name|
  get URI.encode('/api/instances/'+@instance_id), {}
  last_response.status.should == 200
  Nokogiri::XML(last_response.body).xpath("/instance/name").first.text.should == replace_variables(name)
end

Then /^this instance should be image '(.+)'$/ do |image|
  get URI.encode('/api/instances/'+@instance_id), {}
  last_response.status.should == 200
  get URI.parse(Nokogiri::XML(last_response.body).xpath("/instance/image").first[:href]).path, {}
  last_response.status.should == 200
  Nokogiri::XML(last_response.body).xpath("/image/id").first.text.should == replace_variables(image)
end

Then /^this instance should have realm  '(.+)'$/ do |realm|
  get URI.encode('/api/instances/'+@instance_id), {}
  last_response.status.should == 200
  get URI.parse(Nokogiri::XML(last_response.body).xpath("/instance/realm").first[:href]).path, {}
  last_response.status.should == 200
  Nokogiri::XML(last_response.body).xpath("/realm/id").first.text.should == replace_variables(realm)
end

When /^this instance state is '(\w+)'$/ do |given_state|
  state = Nokogiri::XML(last_response.body).xpath("/instance/state").first.text
  state.should == given_state
end

When /^this instance state is '(\w+)' or '(\w+)'$/ do |given_state, given_state_2|
  state = Nokogiri::XML(last_response.body).xpath("/instance/state").first.text
  [given_state, given_state_2].include?(state).should == true
end
