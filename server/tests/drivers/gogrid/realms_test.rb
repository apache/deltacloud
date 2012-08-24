require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'GoGridDriver Realms' do

  before do
    Time.be(DateTime.parse("2012-08-23 11:30:00 +0000").to_s)
    @driver = Deltacloud::new(:gogrid, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.realms(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::ExceptionHandler::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of realms' do
    @driver.realms.wont_be_empty
    @driver.realms.first.must_be_kind_of Realm
  end

  it 'must allow to filter realms' do
    @driver.realms(:id => '1').wont_be_empty
    @driver.realms(:id => '1').must_be_kind_of Array
    @driver.realms(:id => '1').size.must_equal 1
    @driver.realms(:id => '1').first.id.must_equal '1'
    @driver.realms(:id => '1').first.name.must_equal 'US-West-1'
    @driver.realms(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single realm' do
    @driver.realm(:id => '1').wont_be_nil
    @driver.realm(:id => '1').must_be_kind_of Realm
    @driver.realm(:id => '1').id.must_equal '1'
    @driver.realm(:id => '1').name.must_equal 'US-West-1'
    @driver.realm(:id => 'unknown').must_be_nil
  end

end
