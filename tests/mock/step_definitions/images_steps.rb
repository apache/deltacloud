Given /^authentification is required for this URI$/ do
  authorize CONFIG[:username], CONFIG[:password]
  get @uri, {}
  last_response.status.should == 200
end

Then /^this element contains some (.+)$/ do |items|
  item = items.singularize
  output_xml.xpath("/#{@last_element.name}/#{item}").size.should > 0
end

Then /^each ([\w\-]+) should have:$/ do |item, table|
  properties = table.raw.flatten.sort
  output_xml.xpath("/#{@last_element.name}/#{item}").each do |element|
    childrens = (element > '*').collect { |c| c.name }
    childrens.sort.should == properties
  end
end

Then /^this ([\w\-]+) should have:$/ do |item, table|
  properties = table.raw.flatten.sort
  output_xml.xpath("/#{item}").each do |element|
    childrens = (element > '*').collect { |c| c.name }
    childrens.sort.should == properties
  end
end

When /^client want to show first (.+)$/ do |element|
  case element
    when 'image':
      path = '/images/image'
    when 'instance':
      path = '/instances/instance'
    when 'realm':
      path = '/realms/realm'
    when 'hardware_profile'
      path = '/hardware_profiles/hardware_profile'
    when 'storage_volume':
      path = '/storage_volumes/storage_volume'
    when 'storage_snapshot':
      path = '/storage_snapshots/storage_snapshot'
  end
  @element = output_xml.xpath(path).first
  @element.should_not be_nil
end

When /^client want to show '(.+)' (.+)$/ do |id, el|
  @uri = "/api/#{el.pluralize.tr('-', '_')}/#{id}"
  get @uri, {}
  @element = output_xml.xpath("/#{el}").first
  @element.should_not be_nil
end

Then /^client follow (\w+) attribute in first (.+)$/ do |attr, el|
  url = output_xml.xpath("/#{el.pluralize}/#{el}").first[:href]
  url.should_not be_nil
  get url, {}
end

Then /^client should get this (.+)$/ do |el|
  last_response.status.should == 200
end


Then /^client should follow href attribute in (\w+)$/ do |element|
  get @element[:href], {}
end

Then /^client should get valid response with requested (\w+)$/ do |element|
  last_response.status.should == 200
  output_xml.xpath('/'+element).first['id'].to_s.should == @element.xpath('@id').text
end

When /^client access this URI with parameters:$/ do |table|
  params = {}
  table.raw.each { |i| params[i[0]]=i[1] }
  get @uri, params
end

Then /^client should get some ([\w\-]+)$/ do |elements|
  last_response.status.should == 200
  output_xml.xpath('/'+elements+'/'+elements.singularize).size.should > 0
end
