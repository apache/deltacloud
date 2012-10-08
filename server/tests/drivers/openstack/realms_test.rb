require 'minitest/autorun'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'api.rb')
require_relative 'common.rb'

describe 'OpenStackDriver Realms' do

  before do
    @driver = Deltacloud::new(:openstack, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.images(OpenStruct.new(:user => 'unknown+wrong', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of realms' do
    @driver.realms.wont_be_empty
    @driver.realms.first.must_be_kind_of Realm
  end

  it 'must allow to filter realms' do
    realms = @driver.realms :id => 'default'
    realms.wont_be_empty
    realms.must_be_kind_of Array
    realms.size.must_equal 1
    realms.first.id.must_equal 'default'
    @driver.realms(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single realm' do
    realm = @driver.realm :id => 'default'
    realm.wont_be_nil
    realm.id.must_equal 'default'
    realm.limit.wont_be_empty
    realm.state.must_equal 'AVAILABLE'
    @driver.realm(:id => 'unknown').must_be_nil
  end

end
