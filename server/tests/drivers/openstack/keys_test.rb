require 'minitest/autorun'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'api.rb')
require_relative 'common.rb'

describe 'OpenStackDriver Keys' do

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

  it 'must return list of keys' do
    @driver.keys.wont_be_empty
    @driver.keys.first.must_be_kind_of Key
  end

  it 'must allow to filter keys' do
    keys = @driver.keys :id => 'test1'
    keys.wont_be_empty
    keys.must_be_kind_of Array
    keys.size.must_equal 1
    keys.first.name.must_equal 'test1'
    @driver.keys(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single key' do
    key = @driver.key :id => 'test2'
    key.wont_be_nil
    key.name.must_equal 'test2'
    key.fingerprint.wont_be_empty
    key.credential_type.must_equal :key
    key.state.must_equal 'AVAILABLE'
    @driver.key(:id => 'unknown').must_be_nil
  end

  it 'must allow to create and destroy key' do
    key = @driver.create_key(:key_name => 'test-unit-1')
    key.wont_be_nil
    key.id.must_equal 'test-unit-1'
    key.fingerprint.wont_be_empty
    key.pem_rsa_key.wont_be_empty
    key.pem_rsa_key.must_match /^\-\-\-\-\-BEGIN RSA PRIVATE KEY/
    # Should not allow duplicate keys to be created:
    lambda {
      @driver.create_key(:key_name => 'test-unit-1')
    }.must_raise Deltacloud::Exceptions::BackendError
    @driver.destroy_key(:id => 'test-unit-1').must_equal true
  end

end
