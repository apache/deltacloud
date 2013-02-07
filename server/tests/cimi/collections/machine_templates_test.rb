require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require 'minitest/autorun'
require_relative './common.rb'

describe CIMI::Collections::MachineTemplates do

  before do
    def app; run_frontend(:cimi) end
    authorize 'mockuser', 'mockpassword'
    @collection = CIMI::Collections.collection(:machine_images)
  end

  it 'should return bad request creating template with scrambled JSON' do
    json_body = '{
      "resourceURI": "http://schemas.dmtf.org/cimi/1/MachineTemplateCreate",
      "name": "myMachineDemoTemplate",
      "description": "My very loved machine template",
      "machineConfig": { "href": "http://localhost:3001/cimi/machine_configurations/m1-xlarge" }
      "machineImage": { "href": "http://localhost:3001/cimi/machine_images/img1" }
    }'
    header 'Content-Type', 'application/json'
    header 'Accept', 'application/json'
    post root_url('/machine_templates'), json_body
    status.must_equal 400
    json['code'].must_equal 400
    json['message'].must_equal "Bad request (expected ',' or '}' in object at '\"machineImage\": { \"h'!)"
  end

  it 'should return validation error when missing required attribute in JSON' do
    json_body = '{
      "resourceURI": "http://schemas.dmtf.org/cimi/1/MachineTemplateCreate",
      "name": "myMachineDemoTemplate",
      "description": "My very loved machine template",
      "machineConfig": { "href": "http://localhost:3001/cimi/machine_configurations/m1-xlarge" }
    }'
    header 'Content-Type', 'application/json'
    header 'Accept', 'application/json'
    post root_url('/machine_templates'), json_body
    status.must_equal 400
    json['message'].must_equal "Required attributes not set: machineImage"
    json['error'].must_equal 'CIMI::Model::ValidationError'
  end

  it 'should return bad request creating template with scrambled XML' do
    xml_body = '
      <MachineTemplateCreate>
        <name>myXmlTestMachineTemplate1</name>
        <description>Description of my MachineTemplate</description>
        operty key="test">value</property>
        <machineConfig href="http://localhost:3001/cimi/machine_configurations/m1-xlarge"/>
        <machineImage href="http://localhost:3001/cimi/machine_images/img3"/>
      </MachineTemplateCreate>'
    header 'Content-Type', 'text/xml'
    header 'Accept', 'text/xml'
    post root_url('/machine_templates'), xml_body
    status.must_equal 400
    xml.at('/error/message').text.must_equal 'Bad Request'
  end

  it 'should return validation error when missing required attribute in XML' do
    xml_body = '
      <MachineTemplateCreate>
        <name>myXmlTestMachineTemplate1</name>
        <description>Description of my MachineTemplate</description>
        <machineConfig href="http://localhost:3001/cimi/machine_configurations/m1-xlarge"/>
      </MachineTemplateCreate>'
    header 'Content-Type', 'text/xml'
    header 'Accept', 'text/xml'
    post root_url('/machine_templates'), xml_body
    status.must_equal 400
    xml.at('/error/message').text.must_equal "Required attributes not set: machineImage"
    xml.at('/error/parameter').text.must_equal "machineImage"
  end

end
