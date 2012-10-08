require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'MockDriver Keys' do

  before do
    @driver = Deltacloud::new(:mock, :user => 'mockuser', :password => 'mockpassword')
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.keys(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of keys' do
    @driver.keys.wont_be_empty
    @driver.keys.first.must_be_kind_of Key
  end

  it 'must allow to filter keys' do
    @driver.keys(:id => 'test-key').wont_be_empty
    @driver.keys(:id => 'test-key').must_be_kind_of Array
    @driver.keys(:id => 'test-key').size.must_equal 1
    @driver.keys(:id => 'test-key').first.id.must_equal 'test-key'
    @driver.keys(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single key' do
    @driver.key(:id => 'test-key').wont_be_nil
    @driver.key(:id => 'test-key').must_be_kind_of Key
    @driver.key(:id => 'test-key').id.must_equal 'test-key'
    @driver.key(:id => 'unknown').must_be_nil
  end

  it 'must allow to create a new key' do
    key = @driver.create_key(:key_name => 'test1')
    key.wont_be_nil
    key.must_be_kind_of Key
    Proc.new { @driver.create_key(:key_name => 'test1') }.must_raise Deltacloud::Exceptions::ForbiddenError, 'KeyExist'
    @driver.destroy_key :id => key.id
    @driver.key(:id => key.id).must_be_nil
  end

end
