require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'FgcpDriver Realms' do

  before do
    @driver = Deltacloud::new(:fgcp, credentials)
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
    # assume at least one vsys has been created, with at least 1 tier network
    realms.size.wont_be :<, 2
  end

  it 'must allow to filter realms' do
    realms = @driver.realms(:id => 'UZXC0GRT-ZG8ZJCJ07')
    realms.wont_be_empty
    realms.must_be_kind_of Array
    realms.size.must_equal 1
    realms.first.id.must_equal 'UZXC0GRT-ZG8ZJCJ07'
    realms.first.name.must_equal 'Dies-DC-test'
    realms.first.state.must_equal 'AVAILABLE'
    @driver.realms(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single realm' do
    realm = @driver.realm(:id => 'UZXC0GRT-ZG8ZJCJ07-N-DMZ')
    realm.wont_be_nil
    realm.must_be_kind_of Deltacloud::Realm
    realm.state.must_equal 'AVAILABLE'
    realm.id.must_equal 'UZXC0GRT-ZG8ZJCJ07-N-DMZ'
    realm.name.must_equal 'Dies-DC-test [DMZ]'
    @driver.realm(:id => 'unknown').must_be_nil
  end


end
