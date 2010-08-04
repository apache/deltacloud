When /^client want to create a new instance credential$/ do
end

Then /^client should choose name '(\w+)'$/ do |name|
  @name = name
end

Then /^this instance should have id attribute set to '(\w+)'$/ do |name|
  output_xml.xpath('/instance_credential/@id').text.should == name
end

Then /^this instance should have valid fingerprint$/ do
  output_xml.xpath('/instance_credential/fingerprint').text.should_not == nil
  output_xml.xpath('/instance_credential/fingerprint').text.size > 0
end

Then /^this instance should have valid pem key$/ do
  output_xml.xpath('/instance_credential/pem').text.strip =~ /$-----BEGIN RSA PRIVATE KEY-----/
end

When /^client request for a new instance credential$/ do
  params = {
    :name => @name
  }
  post "/api/instance_credentials", params
end

Then /^new instance credential should be created$/ do
  output_xml.xpath('/instance_credential').size.should == 1
end

Then /^this instance should have credential_type set to 'key'$/ do
  output_xml.xpath('/instance_credential/credential_type').text == 'key'
end

Then /^this instance should have destroy action$/ do
  output_xml.xpath('/instance_credential/actions/link[@rel="destroy"]').should_not == nil
end

When /^client want to 'destroy' last instance_credential$/ do
  get "/api/instance_credentials"
  @credential = output_xml.xpath('/instance_credentials/instance_credential').last
end

When /^client follow destroy link in actions$/ do
  @link = output_xml.xpath('/instance_credentials/instance_credential/actions/link[@rel="destroy"]').last
  delete @link['href'], {}
end

Then /^client should get created instance_credential$/ do
  @credential[:id].should == @name
end

Then /^this instance_credential should be destroyed$/ do
  get "/api/instance_credentials/test01"
  last_response.status.should == 200
end
