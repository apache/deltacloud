require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'RhevmDriver Realms' do

  before do
    @driver = Deltacloud::new(:rhevm, credentials)
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
    @driver.realms.wont_be_empty
    @driver.realms.first.must_be_kind_of Realm
  end

  it 'must allow to filter realms' do
    @driver.realms(:id => '99408929-82cf-4dc7-a532-9d998063fa95').wont_be_empty
    @driver.realms(:id => '99408929-82cf-4dc7-a532-9d998063fa95').must_be_kind_of Array
    @driver.realms(:id => '99408929-82cf-4dc7-a532-9d998063fa95').size.must_equal 1
    @driver.realms(:id => '99408929-82cf-4dc7-a532-9d998063fa95').first.id.must_equal '99408929-82cf-4dc7-a532-9d998063fa95'
    @driver.realms(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single realm' do
    @driver.realm(:id => '99408929-82cf-4dc7-a532-9d998063fa95').wont_be_nil
    @driver.realm(:id => '99408929-82cf-4dc7-a532-9d998063fa95').must_be_kind_of Realm
    @driver.realm(:id => 'unknown').must_be_nil
  end

end
