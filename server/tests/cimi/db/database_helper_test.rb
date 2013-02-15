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

  Provider = Deltacloud::Database::Provider
  Entity = Deltacloud::Database::Entity
  BaseModel = CIMI::Model::Base

  before do
    @db = DatabaseHelper.new
    @prov = Provider::lookup
  end

  it 'report if given entity is provided by database' do
    @db.provides?('machine_template').must_equal true
    @db.provides?('machine').must_equal false
  end

  it 'reports the current provider' do
    @db.current_provider.must_equal 'default'
  end

  it 'create provider when it does not exists' do
    @prov.must_be_kind_of Deltacloud::Database::Provider
    @prov.driver.must_equal 'mock'
    @prov.url.must_equal @db.current_provider
    @prov.must_respond_to :entities
    @prov.must_respond_to :machine_templates
    @prov.must_respond_to :address_templates
    @prov.must_respond_to :volume_configurations
    @prov.must_respond_to :volume_templates
  end

  it 'must return entity for given model' do
    @prov.wont_be_nil

    new_entity = @prov.add_entity(
      :name => 'testMachine1',
      :description => 'testMachine1 description',
      :ent_properties => JSON::dump(:key => 'value'),
      :be_kind => BaseModel.name,
      :be_id => 'inst1'
    )

    check_entity_base_attrs new_entity, Entity, @prov

    result = Entity.retrieve(BaseModel.new(:id => 'inst1'))
    result.must_equal new_entity

    new_entity.destroy
    result = Entity.retrieve(BaseModel.new(:id => 'inst1'))
    result.exists?.must_equal false
  end

  it 'must load attributes for entity for given model' do
    @prov.wont_be_nil

    new_entity = @prov.add_entity(
      :name => 'testMachine1',
      :description => 'testMachine1 description',
      :ent_properties => JSON::dump(:key => 'value'),
      :be_kind => BaseModel.name,
      :be_id => 'base1'
    )

    check_entity_base_attrs new_entity, Entity, @prov

    result = Entity::retrieve(BaseModel.new(:id => 'base1'))
    result.name.must_equal new_entity.name
    result.description.must_equal new_entity.description
    result.properties.must_equal new_entity.properties

    new_entity.destroy.wont_equal false
  end

  it 'must delete attributes for entity for given model' do
    @prov.wont_be_nil

    new_entity = @prov.add_entity(
      :name => 'testMachine1',
      :description => 'testMachine1 description',
      :ent_properties => JSON::dump(:key => 'value'),
      :be_kind => BaseModel.name,
      :be_id => 'base1'
    )

    check_entity_base_attrs new_entity, Entity, @prov

    base = BaseModel.new(:id => 'base1')
    base.destroy
    entity = Entity.retrieve(base)
    entity.wont_be_nil
    entity.exists?.must_equal false
  end

  it 'must store attributes for a given CIMI::Model' do
    @prov.wont_be_nil

   json = '
{
  "id": "http://localhost:3001/cimi/machines/42",
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
    machine = CIMI::Model::Machine.from_json(json)
    machine.save

    m2 = CIMI::Model::Machine.new(:id => machine.id)
    m2.name.must_equal 'myDatabaseMachine'
    m2.description.must_equal 'This is a demo machine'
    m2.property.must_be_kind_of Hash
    m2.property.size.must_equal 2
    m2.property['foo'].must_equal 'bar'
    m2.property['life'].must_equal 'is life'
  end
end
