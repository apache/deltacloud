World(Rack::Test::Methods)

Given /^Cloud Entry Point URL is provided$/ do
  get '/cimi'
  last_response.status.should == 301
  last_response.location.should == "http://example.org/cimi/cloudEntryPoint"
end

Given /^client retrieve the Cloud Entry Point$/ do
  get "/cimi/cloudEntryPoint"
  header 'Accept', 'application/xml'
  last_response.status.should == 200
end

When /^client lists ([\w ]+) collection$/ do |col_name|
  authorize 'mockuser', 'mockpassword'
  header 'Accept', 'application/xml'
  get "/cimi/%s" % col_name.to_collection_uri
  last_response.status.should == 200
  puts last_response.body
end

Then /^client should get list of all ([\w ]+)$/ do |col_name|
  root_name = "#{col_name.to_class_name}Collection"
  last_xml_response.root.name.should == root_name
  (last_xml_response/"#{root_name}/name").size.should == 1
  (last_xml_response/"#{root_name}/name").first.text.should == 'default'
  (last_xml_response/"#{root_name}/uri").size.should == 1
  (last_xml_response/"#{root_name}/uri").first.text.should == last_request.url
  (last_xml_response/"#{root_name}/#{col_name.to_class_name}").size.should == 3
  (last_xml_response/"#{root_name}/#{col_name.to_class_name}").each do |machine_img|
    machine_img[:href].should_not be_nil
    machine_img[:href].should =~ /http:\/\/example\.org\/cimi\/#{col_name.to_collection_uri}\/img(\d)/
  end
end

When /^client( should be able to)? query for '(\w+)' ([\w ]+) entity$/ do |s, entity_id, entity_name|
  authorize 'mockuser', 'mockpassword'
  header 'Accept', 'application/xml'
  get "/cimi/%s/%s" % [entity_name.to_entity_uri, entity_id]
  last_response.status.should == 200
  puts last_response.body
  @entity_id = entity_id
end

Then /^client should verify that this ([\w ]+) exists$/ do |entity_name|
  root_name = entity_name.to_class_name
  last_xml_response.root.name.should == root_name
  @entity = last_xml_response
end

Then /^client should verify that this ([\w ]+) has set$/ do |entity, attrs|
  model = CIMI::Model.const_get(entity.to_entity_name).from_xml(last_response.body)
  attrs.rows_hash.each do |key, value|
    if key =~ /^\*/
      model.send(key.gsub(/^\*/, '').intern).href.should == value
    else
      model.send(key.intern).to_s.should == value
    end
  end
end
