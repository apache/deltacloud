require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require 'minitest/autorun'

require_relative 'db_helper.rb'
require_relative '../spec_helper.rb'
require_relative './../collections/common.rb'

describe "Deltacloud::Database::Entity" do

  before do
    @provider = Deltacloud::Database::Provider
    @entity = Deltacloud::Database::Entity
    @baseModel = CIMI::Model::Base
    ENV['RACK_ENV'] = 'development'
    @prov = @provider::lookup
  end

  it 'newly created entities have valid ent_properties' do
    model = @baseModel.new(:id => "/base/42")
    ent = @entity.retrieve(model)
    ent.properties = nil
    ent.exists?.must_equal false
    ent.save

    ent = @entity.retrieve(model)
    ent.exists?.must_equal true
  end
end
