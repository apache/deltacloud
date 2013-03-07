require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'RhevmDriver Realms' do

  before do
    prefs = Deltacloud::Test::config.preferences(:rhevm)
    @dc_id = prefs["datacenter"]

    @driver = Deltacloud::Test::config.driver(:rhevm)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.realms(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of realms' do
    realms = @driver.realms
    realms.wont_be_empty
    realms.first.must_be_kind_of Deltacloud::Realm
  end

  it 'must allow to filter realms' do
    realms = @driver.realms(:id => @dc_id)
    realms.wont_be_empty
    realms.must_be_kind_of Array
    realms.size.must_equal 1
    realms.first.id.must_equal @dc_id
    @driver.realms(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single realm' do
    realm = @driver.realm(:id => @dc_id)
    realm.wont_be_nil
    realm.must_be_kind_of Deltacloud::Realm
    @driver.realm(:id => 'unknown').must_be_nil
  end

end
