require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require 'minitest/autorun'

require_relative 'db_helper.rb'
require_relative '../spec_helper.rb'
require_relative './../collections/common.rb'

class DatabaseHelper
  include Deltacloud::Helpers::Database
end

describe Deltacloud::Helpers::Database do
  include Deltacloud::DatabaseTestHelper

  before do
    ENV['RACK_ENV'] = 'development'
    @db = DatabaseHelper.new
  end

  it 'report if application is running under test environment' do
    ENV['RACK_ENV'] = 'test'
    @db.test_environment?.must_equal true
    ENV['RACK_ENV'] = 'development'
    @db.test_environment?.must_equal false
  end

  it 'report if given entity is provided by database' do
    @db.provides?('machine_template').must_equal true
    @db.provides?('machine').must_equal false
  end

  it 'reports the current provider' do
    @db.current_provider.must_equal 'default'
  end

  it 'create provider when it does not exists' do
    @db.current_db.must_be_kind_of Deltacloud::Database::Provider
    @db.current_db.driver.must_equal 'mock'
    @db.current_db.url.must_equal @db.current_provider
    @db.current_db.must_respond_to :entities
    @db.current_db.must_respond_to :machine_templates
    @db.current_db.must_respond_to :address_templates
    @db.current_db.must_respond_to :volume_configurations
    @db.current_db.must_respond_to :volume_templates
  end

  it 'extract attributes both from JSON and XMLSimple' do
    xml_simple_test = { 'property' => [ { 'key' => 'template', 'content' => "value"} ] }
    json_test = { 'properties' => { 'template' => 'value' } }

    @db.extract_attribute_value('property', xml_simple_test).must_equal('template' => 'value')
    @db.extract_attribute_value('properties', json_test).must_equal('template' => 'value')
  end

  it 'must return entity for given model' do
    provider = Deltacloud::Database::Provider
    entity = Deltacloud::Database::Entity
    @db.current_db.wont_be_nil

    new_entity = @db.current_db.add_entity(
      :name => 'testMachine1',
      :description => 'testMachine1 description',
      :ent_properties => JSON::dump(:key => 'value'),
      :be_kind => 'instance',
      :be_id => 'inst1'
    )

    check_entity_base_attrs new_entity, entity, @db.current_db

    result = @db.get_entity(Instance.new(:id => 'inst1'))
    result.must_equal new_entity

    new_entity.destroy.wont_equal false
  end

  it 'must load attributes for entity for given model' do
    provider = Deltacloud::Database::Provider
    entity = Deltacloud::Database::Entity
    @db.current_db.wont_be_nil

    new_entity = @db.current_db.add_entity(
      :name => 'testMachine1',
      :description => 'testMachine1 description',
      :ent_properties => JSON::dump(:key => 'value'),
      :be_kind => 'instance',
      :be_id => 'inst1'
    )

    check_entity_base_attrs new_entity, entity, @db.current_db

    result = @db.load_attributes_for(Instance.new(:id => 'inst1'))
    result.must_be_kind_of Hash
    result[:name].must_equal new_entity.name
    result[:description].must_equal new_entity.description
    result[:property].must_equal JSON::parse(new_entity.ent_properties)

    new_entity.destroy.wont_equal false
  end

  it 'must delete attributes for entity for given model' do
    provider = Deltacloud::Database::Provider
    entity = Deltacloud::Database::Entity
    @db.current_db.wont_be_nil

    new_entity = @db.current_db.add_entity(
      :name => 'testMachine1',
      :description => 'testMachine1 description',
      :ent_properties => JSON::dump(:key => 'value'),
      :be_kind => 'instance',
      :be_id => 'inst1'
    )

    check_entity_base_attrs new_entity, entity, @db.current_db

    result = @db.delete_attributes_for(Instance.new(:id => 'inst1'))
    result.wont_equal false
    result.exists?.must_equal false
  end

  it 'must store JSON attributes for entity for given model' do
    provider = Deltacloud::Database::Provider
    entity = Deltacloud::Database::Entity
    @db.current_db.wont_be_nil

    mock_instance = Instance.new(:id => 'inst1')
    mock_json = '
{
  "resourceURI": "http://schemas.dmtf.org/cimi/1/MachineCreate",
  "name": "myDatabaseMachine",
  "description": "This is a demo machine",
  "properties": {
    "foo": "bar",
    "life": "is life"
  },
  "machineTemplate": {
    "machineConfig": { "href": "http://localhost:3001/cimi/machine_configurations/m1-small" },
    "machineImage": { "href": "http://localhost:3001/cimi/machine_images/img1" }
  }
}
    '
    result = @db.store_attributes_for(mock_instance, JSON::parse(mock_json))
    result.must_be_kind_of entity
    check_entity_base_attrs result, entity, @db.current_db
    load_result = @db.load_attributes_for(mock_instance)
    load_result.must_be_kind_of Hash
    load_result.wont_be_empty
    load_result[:name].must_equal 'myDatabaseMachine'
    load_result[:description].must_equal 'This is a demo machine'
    load_result[:property].must_be_kind_of Hash
    load_result[:property].wont_be_empty
    load_result[:property]['foo'].must_equal 'bar'
    load_result[:property]['life'].must_equal 'is life'
    result.destroy.wont_equal false
  end

  it 'must store XML attributes for entity for given model' do
    provider = Deltacloud::Database::Provider
    entity = Deltacloud::Database::Entity
    @db.current_db.wont_be_nil

    mock_instance = Instance.new(:id => 'inst1')
    mock_xml = '
<MachineCreate>
  <name>myMachineXML123</name>
  <description>Description of my new Machine</description>
  <machineTemplate>
    <machineConfig href="http://localhost:3001/cimi/machine_configurations/m1-small"/>
    <machineImage href="http://localhost:3001/cimi/machine_images/img1"/>
  </machineTemplate>
  <property key="test">value</property>
  <property key="foo">bar</property>
</MachineCreate>
    '
    result = @db.store_attributes_for(mock_instance, XmlSimple.xml_in(mock_xml))
    result.must_be_kind_of entity
    check_entity_base_attrs result, entity, @db.current_db
    load_result = @db.load_attributes_for(mock_instance)
    load_result.must_be_kind_of Hash
    load_result.wont_be_empty
    load_result[:name].must_equal 'myMachineXML123'
    load_result[:description].must_equal 'Description of my new Machine'
    load_result[:property].must_be_kind_of Hash
    load_result[:property].wont_be_empty
    load_result[:property]['test'].must_equal 'value'
    result.destroy.wont_equal false
  end


end
