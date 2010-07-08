Then /^flavor should have valid href parameter$/ do
  href=Nokogiri::XML(last_response.body).xpath('/flavor').first[:href]
  href.should == "http://example.org/api/flavors/#{CONFIG[$DRIVER][:flavor_id]}"
end

