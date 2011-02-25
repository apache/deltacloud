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