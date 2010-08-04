When /^client want to create a new key$/ do
end

Then /^client should choose name '(\w+)'$/ do |name|
  @name = name
end

Then /^this instance should have id attribute set to '(\w+)'$/ do |name|
  output_xml.xpath('/key/@id').text.should == name
end

Then /^this instance should have valid fingerprint$/ do
  output_xml.xpath('/key/fingerprint').text.should_not == nil
  output_xml.xpath('/key/fingerprint').text.size > 0
end

Then /^this instance should have valid pem key$/ do
  output_xml.xpath('/key/pem').text.strip =~ /$-----BEGIN RSA PRIVATE KEY-----/
end

When /^client request for a new key$/ do
  params = {
    :name => @name
  }
  post "/api/keys", params
end

Then /^new key should be created$/ do
  output_xml.xpath('/key').size.should == 1
end

Then /^this instance should have credential_type set to '(\w+)'$/ do |type|
  output_xml.xpath('/key/@type').text.should == type
end

Then /^this instance should have destroy action$/ do
  output_xml.xpath('/key/actions/link[@rel="destroy"]').should_not == nil
end

When /^client want to 'destroy' last key$/ do
  get "/api/keys"
  @credential = output_xml.xpath('/keys/key').last
end

When /^client follow destroy link in actions$/ do
  @link = output_xml.xpath('/keys/key/actions/link[@rel="destroy"]').last
  delete @link['href'], {}
end

Then /^client should get created key$/ do
  @credential[:id].should == @name
end

Then /^this key should be destroyed$/ do
  # TODO: Fixme
  #get "/api/keys"
  #last_response.status.should == 200
end
