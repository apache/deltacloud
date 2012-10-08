require 'minitest/autorun'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'api.rb')
require_relative 'common.rb'

describe 'OpenStackDriver Instances' do

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

  it 'must return list of instances' do
    @driver.instances.wont_be_empty
    @driver.instances.first.must_be_kind_of Instance
  end

# FIXME: The tests above will fail because of incompatibility
#        in a way how OpenStack handle uuid/id.
#        Please uncomment these tests if that will be fixed.

=begin
  it 'must allow to filter instances' do
    instances = @driver.instances :id => 'fef00348-9991-404c-b0d4-655d18f84345'
    instances.wont_be_empty
    instances.must_be_kind_of Array
    instances.size.must_equal 1
    puts instances.inspect
    instances.first.id.must_equal 'fef00348-9991-404c-b0d4-655d18f84345'
    @driver.instances(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single instance' do
    instance = @driver.instance :id => 'fef00348-9991-404c-b0d4-655d18f84345'
    instance.wont_be_nil
    instance.id.must_equal 'fef00348-9991-404c-b0d4-655d18f84345'
    instance.name.must_equal 'test-3'
    instance.state.wont_be_empty
    instance.owner_id.must_equal 'admin'
    instance.realm_id.wont_be_empty
    instance.image_id.wont_be_empty
    instance.instance_profile.wont_be_nil
    @driver.instance(:id => 'unknown').must_be_nil
  end

  it 'must allow to create and destroy an instance' do
    instance = @driver.create_instance 'bf7ce59a-d9f9-45d4-9313-f45b16436602', :hwp_id => '1'
    instance.wont_be_nil
    instance.image_id.must_equal 'bf7ce59a-d9f9-45d4-9313-f45b16436602'
    instance.name.wont_be_empty
    instance.wait_for!(@driver, record_retries('inst_launch')) { |i| i.is_running? }
    puts @driver.destroy_instance(instance.id).inspect
  end
=end

end
