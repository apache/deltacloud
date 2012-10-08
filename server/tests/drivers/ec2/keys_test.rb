require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'Ec2Driver Keys' do

  before do
    @driver = Deltacloud::new(:ec2, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.images(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of keys' do
    @driver.keys.wont_be_empty
    @driver.keys.first.must_be_kind_of Key
  end

  it 'must allow to filter keys' do
    @driver.keys(:id => 'test1').wont_be_empty
    @driver.keys(:id => 'test1').must_be_kind_of Array
    @driver.keys(:id => 'test1').size.must_equal 1
    @driver.keys(:id => 'test1').first.id.must_equal 'test1'
    @driver.keys(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single key' do
    @driver.key(:id => 'test1').wont_be_nil
    @driver.key(:id => 'test1').must_be_kind_of Key
    @driver.key(:id => 'test1').id.must_equal 'test1'
    @driver.key(:id => 'unknown').must_be_nil
  end

  it 'must allow to create a new key' do
    key = @driver.create_key(:key_name => 'test-key-1')
    key.wont_be_nil
    key.must_be_kind_of Key
    Proc.new { @driver.create_key(:key_name => 'test-key-1') }.must_raise Deltacloud::Exceptions::ProviderError, 'KeyExist'
    @driver.destroy_key :id => key.id
    @driver.key(:id => key.id).must_be_nil
  end

 end
