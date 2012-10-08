require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'MockDriver Realms' do

  before do
    @driver = Deltacloud::new(:mock, :user => 'mockuser', :password => 'mockpassword')
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
    @driver.realms(:id => 'us').wont_be_empty
    @driver.realms(:id => 'us').must_be_kind_of Array
    @driver.realms(:id => 'us').size.must_equal 1
    @driver.realms(:id => 'us').first.id.must_equal 'us'
    @driver.realms(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single realm' do
    @driver.realm(:id => 'us').wont_be_nil
    @driver.realm(:id => 'us').must_be_kind_of Realm
    @driver.realm(:id => 'us').id.must_equal 'us'
    @driver.realm(:id => 'unknown').must_be_nil
  end

end
