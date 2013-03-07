require 'minitest/autorun'
require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'api.rb')
require_relative 'common.rb'

describe 'OpenStackDriver Instances' do

  def credentials
  {
    :user => "foo@fakedomain.eu+foo@fakedomain.eu-default-tenant",
    :password => "1234fake56789",
    :provider =>  "https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/;az-1.region-a.geo-1"
  }
  end

  before do
    @driver = Deltacloud::new(:openstack, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when GET instances with wrong credentials' do
    Proc.new do
      @driver.backend.instances(OpenStruct.new(:user => 'unknown+wrong', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of instances' do
    @driver.instances.wont_be_empty
    @driver.instances.first.must_be_kind_of Deltacloud::Instance
  end

  it 'must allow to filter instances' do
    instances = @driver.instances :id => '815215'
    instances.wont_be_empty
    instances.must_be_kind_of Array
    instances.size.must_equal 1
    instances.first.id.must_equal '815215'
    @driver.instances(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single instance' do
    instance = @driver.instance :id => '815215'
    instance.wont_be_nil
    instance.id.must_equal '815215'
    instance.name.must_equal 'server2013-02-13 13:06:46 +0200'
    instance.state.wont_be_empty
    instance.owner_id.must_equal 'foo@fakedomain.eu'
    instance.realm_id.wont_be_empty
    instance.image_id.wont_be_empty
    instance.instance_profile.wont_be_nil
    @driver.instance(:id => 'unknown').must_be_nil
  end

  it 'must allow to create and destroy an instance' do
    instance = @driver.create_instance '78265', :hwp_id => '100', :realm_id => "az-1.region-a.geo-1"
    instance.wont_be_nil
    instance.image_id.must_equal '78265'
    instance.name.wont_be_empty
    instance.wait_for!(@driver, record_retries('inst_launch')) { |i| i.is_running? }
    @driver.destroy_instance(instance.id)
  end

end
