require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'db_helper.rb'
require_relative '../spec_helper.rb'

describe Deltacloud::Database do

  include Deltacloud::DatabaseTestHelper

  before do
    @db = Deltacloud.database
  end

  it 'has valid database connection' do
    @db.test_connection.must_equal true
  end

  it 'creates the database schema' do
    @db.tables.wont_be_empty
    @db.tables.must_include :providers
    @db.tables.must_include :entities
  end

  it 'should allow creation of providers' do
    provider = Deltacloud::Database::Provider
    provider.table_name.must_equal :providers
    new_provider = provider.create(:driver => 'mock', :url => 'test1')
    new_provider.must_be_kind_of provider
    new_provider.destroy.wont_equal false
  end

  it 'should not allow creation of provider with nil driver' do
    provider = Deltacloud::Database::Provider
    lambda {
      new_provider = provider.create(:driver => nil, :url => 'test1')
    }.must_raise Sequel::InvalidValue
  end

  it 'allow creation of simple entity' do
    provider = Deltacloud::Database::Provider
    entity = Deltacloud::Database::Entity
    entity.table_name.must_equal :entities

    entity_provider = provider.create(:driver => :mock)

    new_entity = entity_provider.add_entity(
      :name => 'testEntity1',
      :description => 'testEntity1 description',
      :ent_properties => JSON::dump(:key => 'value')
    )

    check_entity_base_attrs new_entity, entity, entity_provider

    new_entity.destroy.wont_equal false
    entity_provider.destroy.wont_equal false
  end

  it 'allow creation of extended entities' do
    provider = Deltacloud::Database::Provider
    entity = Deltacloud::Database::MachineTemplate
    entity.table_name.must_equal :entities
    entity_provider = provider.create(:driver => :mock)
    new_entity = entity_provider.add_machine_template(
      :name => 'testMachineTemplate1',
      :description => 'testMachineTemplate1 description',
      :ent_properties => JSON::dump(:key => 'value'),
      :machine_config => 'http://example.com/cimi/machine_configurations/m1-small',
      :machine_image => 'http://example.com/cimi/machine_image/img1'
    )
    check_entity_base_attrs new_entity, entity, entity_provider

    new_entity.machine_config.wont_be_empty
    new_entity.machine_image.wont_be_empty

    new_entity.destroy.wont_equal false
    entity_provider.destroy.wont_equal false
  end

  it 'validate presence of required attributes for extended entities' do
    provider = Deltacloud::Database::Provider
    entity = Deltacloud::Database::MachineTemplate
    entity.table_name.must_equal :entities
    entity_provider = provider.create(:driver => :mock)
    lambda {
      new_entity = entity_provider.add_machine_template(
        :name => 'testMachineTemplate1',
        :description => 'testMachineTemplate1 description',
        :ent_properties => JSON::dump(:key => 'value'),
      )
    }.must_raise Sequel::ValidationFailed
  end

end
