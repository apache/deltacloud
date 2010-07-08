
Then /^image should have valid href parameter$/ do
  href=Nokogiri::XML(last_response.body).xpath('/image').first[:href]
  href.should == "http://example.org/api/images/#{CONFIG[$DRIVER][:image_id]}"
end

