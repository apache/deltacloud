When /^client want create a new ([\w_]+)$/ do |object|
end

When /^client want to list all storage_volumes$/ do
end

When /^client want to attach storage volume to RUNNING instance$/ do
  get "/api/instances", { :state => "RUNNING" }
  @instance_id = (output_xml/"/instances/instance").first[:id]
  get "/api/storage_volumes"
  @storage_volume_id = (output_xml/"/storage_volumes/storage_volume").first[:id]
end

Then /^client should POST on ([\w_\/\$]+) using$/ do |uri, table|
  params = {}
  uri.gsub!(/\$storage_volume_id/, @storage_volume_id) if @storage_volume_id
  table.raw.each do |key, value|
    if value =~ /\$(.*)/
      value = case $1.strip
                when 'instance_id' then @instance_id 
              end
    end
    params[key.to_sym] = value.strip
  end
  post uri, params
end

Then /^client should do a POST on ([\w_\/\$]+)$/ do |uri|
  get "/api/storage_volumes"
  @storage_volume_id = (output_xml/"/storage_volumes/storage_volume").first[:id]
  uri.gsub!(/\$storage_volume_id/, @storage_volume_id) if @storage_volume_id
end

Then /^client should GET on ([\w_\/]+)$/ do |uri|
  get uri
end

Then /^a new storage_volume should be created$/ do
  last_response.status.should == 201
end

Then /^a list of ([\w_]+) should be returned$/ do |collection|
  last_response.status.should == 200
  (output_xml/"/#{collection}").size.should_not == 0
end

Then /^this storage_volume should have (\w+) set to '(\w+)'$/ do |key, val|
  (output_xml/"/storage_volume/#{key}").text.should == val
end

Then /^this storage_volume should have (\w+) with valid date$/ do |key|
  (output_xml/"/storage_volume/#{key}").text.class.should_not == nil
end

Then /^each (\w+) should have (\w+) with valid date$/ do |object, key|
  (output_xml/"/#{object}s/#{object}").each do |item|
    (item/"#{key}").should_not == nil
  end
end

Then /^this storage_volume should have actions:$/ do |table|
  table.raw.each do |key|
    (output_xml/"/storage_volume/actions/link[@rel = '#{key}']").should_not == nil
  end
end

Then /^each (\w+) should have (\w+)$/ do |object, key|
  (output_xml/"/#{object}s/#{object}").each do |item|
    (item/"#{key}").should_not == nil
  end
end

Then /^storage_volume should be attached to this instance$/ do
  get "/api/storage_volumes/vol-de30ccb4"
  (output_xml/"/storage_volume/mount/instance").first['id'].should == 'i-7f6a021e'
end

Then /^this storage_volume should have mounted instance with:$/ do |table|
  table.raw.each do |key|
    (output_xml/"/storage_volume/mount/#{key}").should_not == nil
  end
end

When /^client want to detach created storage volume$/ do
end

Then /^storage_volume should be detached from$/ do
  last_response.status.should == 200
end
