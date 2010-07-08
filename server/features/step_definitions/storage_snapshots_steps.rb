Then /^storage snapshot should have valid href parameter$/ do
  href=Nokogiri::XML(last_response.body).xpath('/storage-snapshot').first[:href]
  href.should == "http://example.org/api/storage_snapshots/#{CONFIG[:storage_snapshot_id]}"
end

Then /^storage snapshot should have storage\-volume with valid href attribute$/ do
  href=Nokogiri::XML(last_response.body).xpath('/storage-snapshot/storage-volume').first[:href]
  href.should == "http://example.org/api/storage_volumes/#{CONFIG[:storage_volume_id]}"
end

When /^I want to get details about storage volume$/ do
  @storage_volume_url=Nokogiri::XML(last_response.body).xpath('/storage-snapshot/storage-volume').first[:href]
end

Then /^I could follow storage volume href attribute$/ do
  url=URI.parse(@storage_volume_url)
  get url.path, {}
  last_response.should_not == nil
end

Then /^this attribute should point me to valid storage volume$/ do
  Nokogiri::XML(last_response.body).xpath("/storage-volume").size.should == 1
end
