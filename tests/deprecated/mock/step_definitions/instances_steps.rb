When /^client follow ([\w\-]+) href attribute in first instance$/ do |element|
  get output_xml.xpath('/instances/instance[1]/'+element).first[:href], {}
end

Then /^client should get valid ([\w\-]+)$/ do |element|
  last_response.status.should == 200
  output_xml.xpath("/#{element}").first.should_not be_nil
end

Then /^each instance should have actions$/ do
  output_xml.xpath('/instances/instance').each do |instance|
    instance.xpath('actions').first.should_not be_nil
  end
end

Then /^each actions should have some links$/ do
  output_xml.xpath('/instances/instance').each do |instance|
    instance.xpath('actions/link').first.should_not be_nil
  end
end

Then /^each link should have valid (\w+) attribute$/ do |attr|
  output_xml.xpath('/instances/instance').each do |instance|
    instance.xpath('actions/link').first[attr].should_not be_nil
  end
end

When /^client want to '(\w+)' first instance$/ do |action|
  @action = action
  @instance = output_xml.xpath('/instances/instance[1]').first
end

When /^client follow link in actions$/ do

  @instance ||= output_xml.xpath("/instance").first
  l = @instance.xpath('actions/link[@rel="'+@action+'"]').first

  if @action.eql?('destroy')
    delete l[:href]
  else
    post l[:href]
  end
  puts last_response.body if last_response.status == 500
  last_response.status.should_not == 500
end

Then /^client should get first instance$/ do
  output_xml.xpath('/instance').first.should_not be_nil
end

Then /^this instance should be in '(.+)' state$/ do |state|
  output_xml.xpath('/instance/state').first.text.should == state
end

When /^client want to create a new instance$/ do
end

Then /^client should choose first image$/ do
  get '/api/images', {}
  @image = output_xml.xpath('/images/image').first
  @image.should_not be_nil
end

When /^client request for a new instance$/ do
  params = {
    :image_id => @image.xpath('@id').first.text
  }
  params[:hwp_id] = @hwp_id if @hwp_id
  post "#{@uri}", params
  last_response.status.should == 201
  @instance_url = last_response.headers['Location']
end

Then /^new instance should be created$/ do
  get @instance_url, {}
  last_response.status.should == 200
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
  get @instance_url
end

When /^this instance should be destroyed$/ do
  get @instance[:href].to_s, {}
  last_response.status.should == 404
  output_xml.xpath('/error').first[:status].should == '404'
end

Then /^client should get HTML form$/ do
  last_response.status.should == 200
  (last_response.body.strip =~ /^<!DOCTYPE html/).should be_true
end

When /^client choose last hardware profile$/ do
  get '/api/hardware_profiles', {}
  @hwp_id = output_xml.xpath('/hardware_profiles/hardware_profile/@id').last.text
end

Then /^this instance should have last hardware profile$/ do
  output_xml.xpath('instance/hardware_profile/@id').first.text.should == @hwp_id
end
