Then /^instance should have launch_time set to valid time$/ do
  time = (xml/'instance/launch_time').first.text
  lambda { Date.parse(time) }.should_not raise_error
end

Then /^instance should be in ([A-Z]+) state$/ do |state|
  (xml/'instance/state').first.text.should == state
end

Then /^instance should have defined actions$/ do |table|
  actions = table.raw.flatten
  (xml/'instance/actions/link').each do |action|
    actions.delete(action[:rel])
  end
  actions.should be_empty
end

Then /^instance should have linked valid$/ do |table|
  original_xml = xml.dup
  table.raw.flatten.each do |link|
    (original_xml/"instance/#{link}").should_not be_empty
    (original_xml/"instance/#{link}").first[:method].should_not nil
    (original_xml/"instance/#{link}").first[:href].should_not nil
    get (original_xml/"instance/#{link}").first[:href], {}
    last_response.status.should == 200
  end
end

Then /^instance should have set of public_addresses$/ do |table|
  addresses = table.raw.flatten
  (xml/'instance/public_addresses/address').each do |address|
    addresses.delete(address.text)
  end
  addresses.should be_empty
end

Then /^I want to ([a-z]+) this instance$/ do |action|
  get @current_collection_url
end

Then /^I follow ([a-z]+) link in actions$/ do |action|
  link = (xml/"instance/actions/link[@rel='#{action}']").first
  @instance_id = (xml/'instance').first[:id]
  if link[:method].eql?('post')
    post link[:href]
  end
  if link[:method].eql?('delete')
    delete link[:href]
  end
end

Then /^this instance should be in ([A-Z]+) state$/ do |state|
  last_response.status.should == 302
end

