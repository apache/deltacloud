When /^client use (\w+) header:$/ do |name, table|
  accept_header = table.raw.flatten.sort
  @no_header = true
  header name, accept_header.first.strip
end

When /^client perform an HTTP request for this URI$/ do
  @params ||= {}
  get @uri, @params
end

Then /^client should get valid (HTML|JSON|XML|PNG) response$/ do |format|
  format = format.strip.downcase
  if format.eql?('html')
    last_response.content_type.should =~ /text\/html/
  elsif format.eql?('xml')
    last_response.content_type.should =~ /application\/xml/
    Nokogiri::XML(last_response.body).xpath('/api').size.should_not == 0
  elsif format.eql?('json')
    last_response.content_type.should =~ /application\/json/
    JSON::parse(last_response.body).class.to_s.should == 'Hash'
  end
end

When /^client accept this URI with parameters:$/ do |table|
  p = table.raw.flatten.sort
  @params ||= {}
  @params[p.first.to_sym] = p.last
end

When /^client wants to get URI '(.*)'$/ do |uri|
  @uri = uri
end
