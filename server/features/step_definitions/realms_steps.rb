Then /^realm should have valid href parameter$/ do
  href=Nokogiri::XML(last_response.body).xpath('/realm').first[:href]
  href.should == "http://example.org/api/realms/#{CONFIG[:realm_id]}"
end
