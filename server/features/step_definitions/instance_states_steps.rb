Then /^I should see list of instance states$/ do
  Nokogiri::XML(last_response.body).root.name.should == 'states'
end
