When /^client follow ([\w\-]+) href attribute in first instance$/ do |element|
  get output_xml.xpath('/instances/instance[1]/'+element).first[:href], {}
end

Then /^client should get valid ([\w\-]+)$/ do |element|
  last_response.status.should == 200
  output_xml.xpath("/#{element}").first.should_not be_nil
end

Then /^each running instance should have actions$/ do
  output_xml.xpath('/instances/instance').each do |instance|
    next if instance.xpath('state').text!='RUNNING'
    instance.xpath('actions').first.should_not be_nil
  end
end

Then /^each actions should have some links$/ do
  output_xml.xpath('/instances/instance').each do |instance|
    next if instance.xpath('state').text!='RUNNING'
    puts instance.to_s
    instance.xpath('actions/link').first.should_not be_nil
  end
end

Then /^each link should have valid (\w+) attribute$/ do |attr|
  output_xml.xpath('/instances/instance').each do |instance|
    next if instance.xpath('state').text!='RUNNING'
    instance.xpath('actions/link').first[attr].should_not be_nil
  end
end

When /^client want to '(\w+)' (first|last) instance$/ do |action, position|
  @action = action
  if position=='first'
    @instance = output_xml.xpath('/instances/instance').first
  else
    @instance = output_xml.xpath('/instances/instance').last
  end
end

When /^client follow link in actions$/ do

  unless @instance.xpath('id')
    l = output_xml.xpath('/instances/instance[1]/actions/link[@rel="'+@action+'"]').first
  else
    l = @instance.xpath('actions/link[@rel="'+@action+'"]').first
  end

  post l[:href], { :id => @instance.xpath('@id').first.text }

  last_response.status.should_not == 500
end

Then /^client should get (first|last) instance$/ do |position|
  if position == 'last'
    output_xml.xpath('/instance/id').last.should_not be_nil
  else
    output_xml.xpath('/instance/id').first.should_not be_nil
  end
end

Then /^this instance should be in '(.+)' state$/ do |state|
  output_xml.xpath('/instance/state').first.text.should == state
end

When /^client want to create a new instance$/ do
end

Then /^client should choose (\w+) image$/ do |position|
  get '/api/images', {}
  if position=='first'
    @image = output_xml.xpath('/images/image').first
  else
    @image = output_xml.xpath('/images/image').last
  end
  @image.should_not be_nil
end

When /^client request for a new instance$/ do
  params = {
    :image_id => @image.xpath('@id').first.text
  }
  params[:hwp_id] = @hwp_id if @hwp_id
  post "#{@uri}", params
end

Then /^new instance should be created$/ do
  last_response.status.should == 201
end

Then /^this instance should have chosed image$/ do
  output_xml.xpath('/instance/image').first[:href].should == @image[:href]
end

Then /^this instance should have valid id$/ do
  output_xml.xpath('instance/@id').first.should_not be_nil
end

Then /^this instance should have name$/ do
  output_xml.xpath('instance/name').first.should_not be_nil
end

When /^client want to '(\w+)' created instance$/ do |action|
  get @instance_url, {}
  last_response.status.should == 200
  @action = action
  @instance = output_xml.xpath('/instance')
end

Then /^client should get created instance$/ do
  last_response.status.should == 302
  get last_response.headers['Location']
end

When /^this instance should be destroyed$/ do
  # TODO: Fix this bug in mock driver ?
end

Then /^client should get HTML form$/ do
  last_response.status.should == 200
  (last_response.body.strip =~ /^<!DOCTYPE html/).should be_true
end

When /^client choose (\w+) hardware profile$/ do |position|
  get '/api/hardware_profiles', {}
  if position=='last'
    @hwp_id = output_xml.xpath('/hardware_profiles/hardware_profile/@id').last.text
  else
    @hwp_id = output_xml.xpath('/hardware_profiles/hardware_profile/@id').first.text
  end
end

Then /^this instance should have last hardware profile$/ do
  output_xml.xpath('instance/hardware_profile/@id').first.text.should == @hwp_id
end

Given /^I set mock scenario to (\w+)$/ do |scenario|
  @scenario = scenario
end

Then /^I set mock scenario to default$/ do
  @scenario = ''
end
