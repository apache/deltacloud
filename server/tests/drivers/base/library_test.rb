require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

require_relative '../../../lib/deltacloud/api'

describe 'Deltacloud API Library' do

  it 'should return the driver configuration' do
    Deltacloud.must_respond_to :drivers
    Deltacloud.drivers.wont_be_nil
    Deltacloud.drivers.must_be_kind_of Hash
  end

  it 'should be constructed just using the driver parameter' do
    Deltacloud.new(:mock).must_be_instance_of Deltacloud::Library
    Deltacloud.new(:mock).current_provider.must_be_nil
    Deltacloud.new(:mock).current_driver.must_equal 'mock'
    Deltacloud.new(:mock).backend.must_be_instance_of Deltacloud::Drivers::Mock::MockDriver
    Deltacloud.new(:mock).credentials.user.must_equal 'mockuser'
    Deltacloud.new(:mock).credentials.password.must_equal 'mockpassword'
  end

  it 'should allow to set credentials' do
    Deltacloud.new(:mock, :user => 'testuser', :password => 'testpassword').credentials.user.must_equal 'testuser'
    Deltacloud.new(:mock, :user => 'testuser', :password => 'testpassword').credentials.password.must_equal 'testpassword'
  end

  it 'should allow to set the provider' do
    Deltacloud.new(:mock, :provider => 'someprovider').current_provider.must_equal 'someprovider'
    Deltacloud.new(:mock).current_provider.must_be_nil
  end

  it 'should yield the backend driver' do
    Deltacloud.new :mock do |mock|
      mock.must_be_instance_of Deltacloud::Drivers::Mock::MockDriver
    end
  end

  it 'should return the API version' do
    Deltacloud::API_VERSION.wont_be_empty
    Deltacloud::new(:mock).version.wont_be_empty
  end

end
