require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'RhevmDriver Instances' do

  before do
    @driver = Deltacloud::new(:rhevm, credentials)
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
    @driver.instances(:id => 'de048029-c4f8-4e90-ac7b-67cf06102190').wont_be_empty
    @driver.instances(:id => 'de048029-c4f8-4e90-ac7b-67cf06102190').must_be_kind_of Array
    @driver.instances(:id => 'de048029-c4f8-4e90-ac7b-67cf06102190').size.must_equal 1
    @driver.instances(:id => 'de048029-c4f8-4e90-ac7b-67cf06102190').first.id.must_equal 'de048029-c4f8-4e90-ac7b-67cf06102190'
    @driver.instances(:owner_id => 'admin@internal').wont_be_empty
    @driver.instances(:owner_id => 'admin@internal').each do |inst|
      inst.owner_id.must_equal 'admin@internal'
    end
    @driver.instances(:id => 'i-00000000').must_be_empty
    @driver.instances(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single instance' do
    @driver.instance(:id => 'de048029-c4f8-4e90-ac7b-67cf06102190').wont_be_nil
    @driver.instance(:id => 'de048029-c4f8-4e90-ac7b-67cf06102190').must_be_kind_of Instance
    @driver.instance(:id => 'de048029-c4f8-4e90-ac7b-67cf06102190').id.must_equal 'de048029-c4f8-4e90-ac7b-67cf06102190'
    @driver.instance(:id => 'i-00000000').must_be_nil
    @driver.instance(:id => 'unknown').must_be_nil
  end

  it 'must allow to create a new instance and destroy it' do
    instance = @driver.create_instance('5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5',
                                       :realm_id => '99408929-82cf-4dc7-a532-9d998063fa95',
                                       :hwp_id => 'SERVER',
                                       :hwp_memory => '1024',
                                       :user_data => 'test user data'
                                      )
    instance = instance.wait_for!(@driver, record_retries) { |i| i.is_stopped? }
    instance.must_be_kind_of Instance
    instance.is_running?.must_equal false
    @driver.instance(:id => instance.id).wont_be_nil
    @driver.instance(:id => instance.id).id.must_equal instance.id
    @driver.instance(:id => instance.id).name.wont_be_nil
    @driver.instance(:id => instance.id).instance_profile.name.must_equal 'SERVER'
    @driver.instance(:id => instance.id).instance_profile.memory.must_equal 1024
    @driver.instance(:id => instance.id).realm_id.must_equal '99408929-82cf-4dc7-a532-9d998063fa95'
    @driver.instance(:id => instance.id).image_id.must_equal '5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5'
    @driver.instance(:id => instance.id).owner_id.must_equal 'admin@internal'
    @driver.instance(:id => instance.id).state.must_equal 'STOPPED'
    @driver.instance(:id => instance.id).actions.must_include :start
    @driver.destroy_instance(instance.id)
    instance.wait_for!(@driver, record_retries('destroy')) { |i| i.nil? }
  end

  it 'must allow to create a new instance and make it running' do
    instance = @driver.create_instance('5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5',
                                       :realm_id => '99408929-82cf-4dc7-a532-9d998063fa95',
                                       :hwp_id => 'SERVER',
                                       :hwp_memory => '1024',
                                       :user_data => 'test user data'
                                      )
    instance = instance.wait_for!(@driver, record_retries) { |i| i.is_stopped? }
    instance.must_be_kind_of Instance
    instance.is_running?.must_equal false
    @driver.instance(:id => instance.id).wont_be_nil
    @driver.instance(:id => instance.id).id.must_equal instance.id
    @driver.instance(:id => instance.id).name.wont_be_nil
    @driver.instance(:id => instance.id).instance_profile.name.must_equal 'SERVER'
    @driver.instance(:id => instance.id).instance_profile.memory.must_equal 1024
    @driver.instance(:id => instance.id).realm_id.must_equal '99408929-82cf-4dc7-a532-9d998063fa95'
    @driver.instance(:id => instance.id).image_id.must_equal '5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5'
    @driver.instance(:id => instance.id).owner_id.must_equal 'admin@internal'
    @driver.instance(:id => instance.id).state.must_equal 'STOPPED'
    @driver.instance(:id => instance.id).actions.must_include :start
    @driver.start_instance(instance.id)
    instance = instance.wait_for!(@driver, record_retries('start')) { |i| i.is_running? }
    @driver.instance(:id => instance.id).state.must_equal 'RUNNING'
    Proc.new { @driver.destroy_instance(instance.id) }.must_raise Deltacloud::Exceptions::BackendError, 'Cannot remove VM. VM is running.'
    @driver.stop_instance(instance.id)
    instance = instance.wait_for!(@driver, record_retries('stop')) { |i| i.is_stopped? }
    @driver.instance(:id => instance.id).state.must_equal 'STOPPED'
    @driver.destroy_instance(instance.id)
    instance.wait_for!(@driver, record_retries('destroy')) { |i| i.nil? }
  end

end
