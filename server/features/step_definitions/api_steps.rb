When /^I request for entry points$/ do
  get "/api", { }
  last_response.status.should == 200
end

Then /^I should see these entry points:$/ do |table|
  Nokogiri::XML(last_response.body).xpath('/api/link').each do |entry_point|
    table.raw.flatten.include?(entry_point[:rel]).should == true
  end
end

Then /^I should get valid HTML response$/ do
  Nokogiri::HTML(last_response.body).root.name.should == 'html'
end

Then /^I should see these entry points in page:$/ do |table|
  @links = []
  Nokogiri::HTML(last_response.body).css('div#content ul li a').each do |link|
    @links << link[:href]
  end
  table.raw.flatten.each do |link|
    @links.include?("/api/#{link}").should == true
  end
end

When /^I follow this entry points$/ do
  @responses = []
  authorize CONFIG[:username], CONFIG[:password]
  @links.each do |link|
    get link, {}
    @responses << last_response.status
  end
end

Then /^I should get valid HTML response for each$/ do
  @responses.uniq.should == [200]
end

Then /^each entry points should have documentation$/ do
  @links.each do |link|
    next if link.eql?('/api/docs')
    get link.to_s.gsub(/\/api\//, '/api/docs/'), {}
    last_response.status.should == 200
  end
end
