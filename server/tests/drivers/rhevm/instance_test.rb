require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

TST_REALM    = 'b91b0346-4ba3-11e2-a3ac-0050568c6b2d'
TST_INSTANCE = '28c7428b-834a-46b6-8d21-bf350e00e3d7'
TST_IMAGE    = '3cd2891a-9a0f-44c8-8dec-6280efa278e3'

describe 'RhevmDriver Instances' do

  before do
    # Read credentials from ${HOME/.deltacloud/config
    @driver = Deltacloud::Test::config.driver(:rhevm,
      provider="https://10.16.120.71/api;b9bb11c2-f397-4f41-a57b-7ac15a894779")
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

  it 'must return list of instances' do
    @driver.instances.wont_be_empty
    @driver.instances.first.must_be_kind_of Instance
  end

  it 'must allow to filter instances' do
    @driver.instances(:id =>TST_INSTANCE).wont_be_empty
    @driver.instances(:id =>TST_INSTANCE).must_be_kind_of Array
    @driver.instances(:id =>TST_INSTANCE).size.must_equal 1
    @driver.instances(:id => TST_INSTANCE).first.id.must_equal TST_INSTANCE
    @driver.instances(:id => 'i-00000000').must_be_empty
    @driver.instances(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single instance' do
    @driver.instance(:id => TST_INSTANCE).wont_be_nil
    @driver.instance(:id => TST_INSTANCE).wont_be_nil
    @driver.instance(:id => TST_INSTANCE).must_be_kind_of Instance
    @driver.instance(:id => TST_INSTANCE).id.must_equal TST_INSTANCE
    @driver.instance(:id => 'i-00000000').must_be_nil
    @driver.instance(:id => 'unknown').must_be_nil
  end

  it 'must allow to create a new instance and destroy it' do
    instance = @driver.create_instance(TST_IMAGE,
                                       :realm_id => TST_REALM,
                                       :hwp_id => 'SERVER',
                                       :hwp_memory => '1024',
                                       :user_data => 'test user data'
                                      )
    instance = instance.wait_for!(@driver, record_retries('', :timeout => 60)) { |i| i.is_stopped? }
    instance.must_be_kind_of Instance
    instance.is_running?.must_equal false
    @driver.instance(:id => instance.id).wont_be_nil
    @driver.instance(:id => instance.id).id.must_equal instance.id
    @driver.instance(:id => instance.id).name.wont_be_nil
    @driver.instance(:id => instance.id).instance_profile.name.must_equal 'SERVER'
    @driver.instance(:id => instance.id).instance_profile.memory.must_equal 1024
    @driver.instance(:id => instance.id).realm_id.must_equal TST_REALM
    @driver.instance(:id => instance.id).image_id.must_equal TST_IMAGE
    @driver.instance(:id => instance.id).state.must_equal 'STOPPED'
    @driver.instance(:id => instance.id).actions.must_include :start
    @driver.destroy_instance(instance.id)
    instance.wait_for!(@driver, record_retries('destroy')) { |i| i.nil? }
  end


  it 'must allow to create a new instance and make it running' do
    instance = @driver.create_instance(TST_IMAGE,
                                       :realm_id => TST_REALM,
                                       :hwp_id => 'SERVER',
                                       :hwp_memory => '1024',
                                       :user_data => 'test user data'
                                      )
    instance = instance.wait_for!(@driver, record_retries('', :timeout => 60)) { |i| i.is_stopped? }
    skip "Skip this test due to RHEVm bug: https://bugzilla.redhat.com/show_bug.cgi?id=910741"
    instance.must_be_kind_of Instance
    instance.is_running?.must_equal false
    @driver.instance(:id => instance.id).wont_be_nil
    @driver.instance(:id => instance.id).id.must_equal instance.id
    @driver.instance(:id => instance.id).name.wont_be_nil
    @driver.instance(:id => instance.id).instance_profile.name.must_equal 'SERVER'
    @driver.instance(:id => instance.id).instance_profile.memory.must_equal 1024
    @driver.instance(:id => instance.id).realm_id.must_equal TST_REALM
    @driver.instance(:id => instance.id).image_id.must_equal TST_IMAGE
    @driver.instance(:id => instance.id).state.must_equal 'STOPPED'
    @driver.instance(:id => instance.id).actions.must_include :start
    @driver.start_instance(instance.id)
    instance = instance.wait_for!(@driver, record_retries('start', :timeout => 60)) { |i| i.is_running? }
    @driver.instance(:id => instance.id).state.must_equal 'RUNNING'
    @driver.instance(:id => instance.id).actions.must_include :stop
    Proc.new do
      @driver.destroy_instance(instance.id)
    end.must_raise Deltacloud::Exceptions::BackendError, 'Cannot remove VM. VM is running.'
    @driver.stop_instance(instance.id)
    instance = instance.wait_for!(@driver, record_retries('stop', :timeout => 60)) { |i| i.is_stopped?  }
    @driver.instance(:id => instance.id).state.must_equal 'STOPPED'
    @driver.destroy_instance(instance.id)
    instance.wait_for!(@driver, record_retries('destroy', :timeout => 60)) { |i| i.nil? }
  end

end
