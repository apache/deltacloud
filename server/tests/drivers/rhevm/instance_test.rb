require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'RhevmDriver Instances' do

  before do
    prefs = Deltacloud::Test::config.preferences(:rhevm)
    @dc_id = prefs["datacenter"]
    @vm_id = prefs["vm"]
    @template_id = prefs["template"]

    @driver = Deltacloud::Test::config.driver(:rhevm)
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
    @driver.instances.first.must_be_kind_of Deltacloud::Instance
  end

  it 'must allow to filter instances' do
    insts = @driver.instances(:id =>@vm_id)
    insts.wont_be_empty
    insts.must_be_kind_of Array
    insts.size.must_equal 1
    insts.first.id.must_equal @vm_id
    @driver.instances(:id => 'i-00000000').must_be_empty
    @driver.instances(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single instance' do
    inst = @driver.instance(:id => @vm_id)
    inst.wont_be_nil
    inst.must_be_kind_of Deltacloud::Instance
    inst.id.must_equal @vm_id
    @driver.instance(:id => 'i-00000000').must_be_nil
    @driver.instance(:id => 'unknown').must_be_nil
  end

  it 'must allow to create a new instance and destroy it' do
    instance = @driver.create_instance(@template_id,
                                       :realm_id => @dc_id,
                                       :hwp_id => 'SERVER',
                                       :hwp_memory => '1024',
                                       :user_data => 'test user data'
                                      )
    instance = instance.wait_for!(@driver, record_retries('', :timeout => 60)) { |i| i.is_stopped? }
    instance.must_be_kind_of Deltacloud::Instance
    instance.is_running?.must_equal false

    inst = @driver.instance(:id => instance.id)
    inst.wont_be_nil
    inst.id.must_equal instance.id
    inst.name.wont_be_nil
    inst.instance_profile.name.must_equal 'SERVER'
    inst.instance_profile.memory.must_equal 1024
    inst.realm_id.must_equal @dc_id
    inst.image_id.must_equal @template_id
    inst.state.must_equal 'STOPPED'
    inst.actions.must_include :start
    @driver.destroy_instance(instance.id)
    instance.wait_for!(@driver, record_retries('destroy')) { |i| i.nil? }
  end


  it 'must allow to create a new instance and make it running' do
    instance = @driver.create_instance(@template_id,
                                       :realm_id => @dc_id,
                                       :hwp_id => 'SERVER',
                                       :hwp_memory => '1024',
                                       :user_data => 'test user data'
                                      )
    instance = instance.wait_for!(@driver, record_retries('', :timeout => 60)) { |i| i.is_stopped? }
    skip "Skip this test due to RHEVm bug: https://bugzilla.redhat.com/show_bug.cgi?id=910741"
    instance.must_be_kind_of Deltacloud::Instance
    instance.is_running?.must_equal false

    inst = @driver.instance(:id => instance.id)
    inst.wont_be_nil
    inst.id.must_equal instance.id
    inst.name.wont_be_nil
    inst.instance_profile.name.must_equal 'SERVER'
    inst.instance_profile.memory.must_equal 1024
    inst.realm_id.must_equal @dc_id
    inst.image_id.must_equal @template_id
    inst.state.must_equal 'STOPPED'
    inst.actions.must_include :start

    @driver.start_instance(instance.id)
    instance = instance.wait_for!(@driver, record_retries('start', :timeout => 60)) { |i| i.is_running? }

    inst = @driver.instance(:id => instance.id)
    inst.state.must_equal 'RUNNING'
    inst.actions.must_include :stop

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
