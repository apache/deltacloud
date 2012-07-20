Then /^states element contains some states$/ do
  output_xml.xpath('/states/state').size.should > 0
end

Then /^each state should have '(.+)' attribute$/ do |attr|
  output_xml.xpath('/states/state').each do |state|
    state[attr].should_not be_nil
  end
end

Then /^(\w+) state should have '(.+)' attribute set to '(\w+)'$/ do |pos, attr, value|
  output_xml.xpath('/states/state').first[attr].should==value if pos=='first'
  output_xml.xpath('/states/state').last[attr].should==value if pos=='last'
end

Then /^some states should have transitions$/ do
  @transitions = output_xml.xpath('/states/state/transition')
  @transitions.size.should > 0
end

Then /^each transitions should have 'to' attribute$/ do
  @transitions.each do |t|
    t[:to].should_not be_nil
  end
end

When /^client wants (\w+) format$/ do |format|
  get @uri, { :format => format.downcase }
end

Then /^client should get PNG image$/ do
  last_response.status.should == 200
  last_response.headers['Content-Type'].should =~ /^image\/png/
end
