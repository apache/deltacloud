require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require 'minitest/autorun'

require_relative 'db_helper.rb'
require_relative '../spec_helper.rb'
require_relative './../collections/common.rb'

describe "Deltacloud::Database::Entity" do
  Provider = Deltacloud::Database::Provider
  Entity = Deltacloud::Database::Entity
  BaseModel = CIMI::Model::Base

  before do
    ENV['RACK_ENV'] = 'development'
    @prov = Provider::lookup
  end

  it 'newly created entities have valid ent_properties' do
    model = BaseModel.new(:id => "/base/42")
    ent = Entity.retrieve(model)
    ent.properties = nil
    ent.exists?.must_equal false
    ent.save

    ent = Entity.retrieve(model)
    ent.exists?.must_equal true
  end
end
