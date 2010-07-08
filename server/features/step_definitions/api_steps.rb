When /^I request for entry points$/ do
  get "/api", { }
end

Then /^I should see this entry points:$/ do |table|
  tp = table.raw.flatten
  Nokogiri::XML(last_response.body).xpath('/api/link').each do |entry_point|
    tp.include?(entry_point[:rel]).should == true
  end
end

