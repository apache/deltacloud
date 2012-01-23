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
  @new_machine_name = machine.raw[0][1]
  @builder = Nokogiri::XML::Builder.new do |xml|
    xml.MachineCreate(:xmlns => CMWG_NAMESPACE) {
      xml.name @new_machine_name
      xml.description machine.raw[1][1]
      xml.machineTemplate {
        xml.machineConfig( :href => @machine_configuration.uri )
        xml.machineImage( :href => @machine_image.uri )
      }
    }
  end
end

Then /^client should be able to create this Machine$/ do
  authorize 'mockuser', 'mockpassword'
  header 'Content-Type', 'application/xml'
  post '/cimi/machines', @builder.to_xml
  if [500, 501, 502].include? last_response.status
    puts last_response.body
  end
  last_response.status.should == 201
  set_new_machine(CIMI::Model::Machine.from_xml(last_response.body))
end

Then /^client query for created Machine entity$/ do
  authorize 'mockuser', 'mockpassword'
  header 'Content-Type', 'application/xml'
  get "/cimi/machines/%s" % new_machine.name
  if [500, 501, 502].include? last_response.status
    puts last_response.body
  end
  if @delete_operation
    last_response.status.should == 404
  else
    last_response.status.should == 200
    @machine = CIMI::Model::Machine.from_xml(last_response.body)
    @machine.name.should == new_machine.name
  end

end

Then /^client should verify that this Machine has been created properly$/ do |attrs|
  attrs.rows_hash.each do |key, value|
    if key == 'memory'
      @machine.memory['quantity'].to_s.should == value
    else
      @machine.send(key.intern).to_s.should == value
    end
  end
end

When /^client executes (\w+) operation on created Machine$/ do |operation|
  builder = Nokogiri::XML::Builder.new do |xml|
    xml.Action(:xmlns => CMWG_NAMESPACE) {
      xml.action "http://www.dmtf.org/cimi/action/#{operation}"
    }
  end
  authorize 'mockuser', 'mockpassword'
  header 'Content-Type', 'application/xml'
  if operation == 'delete'
    delete "/cimi/machines/%s" % new_machine.name
    last_response.status.should == 200
    last_response.body.should be_empty
    @delete_operation = true
  else
    post "/cimi/machines/%s/%s" % [new_machine.name, operation], builder.to_xml
    last_response.status.should == 202
    last_response.body.should be_empty
  end
end

Then /^client should verify that this machine is (\w+)$/ do |status|
  unless @delete_operation
    @machine.state.should == status.upcase
  end
end
