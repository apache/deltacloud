Then /^storage volume should have valid href parameter$/ do
  href=Nokogiri::XML(last_response.body).xpath('/storage-volume').first[:href]
  href.should == "http://example.org/api/storage_volumes/#{CONFIG[:storage_volume_id]}"
end

Then /^I could follow instance href attribute$/ do
  instance = Nokogiri::XML(last_response.body).xpath('/storage-volume/instance').first
  instance.should_not == nil
  instance_url = URI.parse(instance[:href]).path
  instance_url.should_not == ''
  get instance_url, {}
  last_response.body.strip.should_not == ''
end

Then /^this attribute should point me to valid instance$/ do
  Nokogiri::XML(last_response.body).root.name.should == 'instance'
  Nokogiri::XML(last_response.body).xpath('/instance/id').first.text.should == CONFIG[:storage_volume_instance]
end
