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

When /^client specifies a Machine Image$/ do |machine_image|
  header 'Accept', 'application/xml'
  authorize 'mockuser', 'mockpassword'
  get machine_image.raw[0][1]
  last_response.status.should == 200
  @machine_image = CIMI::Model::MachineImage.from_xml(last_response.body)
  @machine_image.should_not be_nil
  @machine_image.uri.should == machine_image.raw[0][1]
end

When /^client specifies a Machine Configuration$/ do |machine_conf|
  header 'Accept', 'application/xml'
  authorize 'mockuser', 'mockpassword'
  get machine_conf.raw[0][1]
  last_response.status.should == 200
  @machine_configuration = CIMI::Model::MachineImage.from_xml(last_response.body)
  @machine_configuration.should_not be_nil
  @machine_configuration.uri.should == machine_conf.raw[0][1]
end

When /^client specifies a new Machine using$/ do |machine|
  @machine_image.should_not be_nil
  @machine_configuration.should_not be_nil
  @builder = Nokogiri::XML::Builder.new do |xml|
    xml.Machine(:xmlns => CMWG_NAMESPACE) {
      xml.name machine.raw[0][1]
      xml.description machine.raw[1][1]
      xml.MachineTemplate {
        xml.MachineConfig( :href => @machine_configuration.uri )
        xml.MachineImage( :href => @machine_image.uri )
      }
    }
  end
end

Then /^client should be able to create this Machine$/ do
  pending "NOTE: There is an inconsistency between Primer and CIMI spec\n"
  @machine = CIMI::Model::Machine.from_xml(@builder.to_xml)
  authorize 'mockuser', 'mockpassword'
  post '/cimi/machines', @machine
  last_response.status.should == 201
end

When /^client query for '(\w+)' Machine$/ do |machine_id|
  header 'Accept', 'application/xml'
  authorize 'mockuser', 'mockpassword'
  get "/cimi/machines/%s" % machine_id
end

Then /^client should verify that this machine exists$/ do
  last_xml_response.root.name == 'Machine'
  last_response.status == 200
  @new_machine = last_xml_response
end

Then /^client should be able to query this Machine$/ do
  get "/cimi/machines/%s" % (@new_machine/'')
end

When /^client executes (\w+) operation on Machine '(\w+)'$/ do |operation, machine_id|
  pending # express the regexp above with the code you wish you had
end

Then /^client should verify that this machine is (\w+)$/ do |status|
  pending # express the regexp above with the code you wish you had
end
