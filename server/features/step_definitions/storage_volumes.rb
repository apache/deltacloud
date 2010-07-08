Then /^storage volume should have valid href parameter$/ do
  href=Nokogiri::XML(last_response.body).xpath('/storage-volume').first[:href]
  href.should == "http://example.org/api/storage_volumes/vol2"
end
