require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'Ec2Driver Instances' do

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

  it 'must return list of instances' do
    @driver.instances.wont_be_empty
    @driver.instances.first.must_be_kind_of Instance
  end

  it 'must allow to filter instances' do
    @driver.instances(:id => 'i-4d15f036').wont_be_empty
    @driver.instances(:id => 'i-4d15f036').must_be_kind_of Array
    @driver.instances(:id => 'i-4d15f036').size.must_equal 1
    @driver.instances(:id => 'i-4d15f036').first.id.must_equal 'i-4d15f036'
    @driver.instances(:owner_id => '293787749884').wont_be_empty
    @driver.instances(:owner_id => '293787749884').each do |inst|
      inst.owner_id.must_equal '293787749884'
    end
    @driver.instances(:id => 'i-00000000').must_be_empty
    @driver.instances(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single instance' do
    @driver.instance(:id => 'i-4d15f036').wont_be_nil
    @driver.instance(:id => 'i-4d15f036').must_be_kind_of Instance
    @driver.instance(:id => 'i-4d15f036').id.must_equal 'i-4d15f036'
    @driver.instance(:id => 'i-00000000').must_be_nil
    @driver.instance(:id => 'unknown').must_be_nil
  end

  it 'must allow to create a new instance if instance supported' do
    instance = @driver.create_instance('ami-aecd60c7',
                                       :realm_id => 'us-east-1a',
                                       :hwp_id => 't1.micro',
                                       :keyname => 'test1',
                                       :user_data => 'test user data',
                                       :'firewalls1' => 'default'
                                      )
    instance = instance.wait_for!(@driver, record_retries) { |i| i.is_running? }
    instance.must_be_kind_of Instance
    instance.is_running?.must_equal true
    @driver.instance(:id => instance.id).wont_be_nil
    @driver.instance(:id => instance.id).id.must_equal instance.id
    @driver.instance(:id => instance.id).image_id.must_equal 'ami-aecd60c7'
    @driver.instance(:id => instance.id).name.wont_be_nil
    @driver.instance(:id => instance.id).instance_profile.name.must_equal 't1.micro'
    @driver.instance(:id => instance.id).realm_id.must_equal 'us-east-1a'
    @driver.instance(:id => instance.id).owner_id.must_equal '293787749884'
    @driver.instance(:id => instance.id).keyname.must_equal 'test1'
    @driver.instance(:id => instance.id).firewalls.must_include 'default'
    @driver.instance(:id => instance.id).state.must_equal 'RUNNING'
    @driver.instance(:id => instance.id).public_addresses.wont_be_empty
    @driver.instance(:id => instance.id).actions.must_include :reboot
    @driver.instance(:id => instance.id).actions.must_include :stop
    @driver.destroy_instance(instance.id)
    instance.wait_for!(@driver, record_retries('stopped')) { |i| i.is_stopped? }
  end

  it 'must allow to create multiple instances using the "instance_count" parameter' do
    instances = @driver.create_instance('ami-aecd60c7',
                                       :realm_id => 'us-east-1a',
                                       :hwp_id => 't1.micro',
                                       :instance_count => '2'
                                      )
    instances.wont_be_empty
    instances.size.must_equal 2
    instances.each { |i| i.must_be_kind_of Instance }
    instances = instances.map { |instance| instance.wait_for!(@driver, record_retries("#{instance.id}-running")) { |i| i.is_running? } }
    instances.each { |i| i.is_running?.must_equal true }
    instances.each { |i| @driver.destroy_instance(i.id) }
    instances = instances.map { |instance| instance.wait_for!(@driver, record_retries("#{instance.id}-stopped")) { |i| i.is_stopped? } }
    instances.each { |i| i.is_stopped?.must_equal true }
  end

  it 'must allow creating instance in a VPC subnet' do
    realm_id = "#{@@subnet[:availability_zone]}:#{@@subnet[:subnet_id]}"
    instance = @driver.create_instance('ami-aecd60c7',
                                       :realm_id => realm_id,
                                       :hwp_id => 'm1.small')
    instance.must_be_kind_of Instance
    instance.realm_id.must_equal realm_id
    @driver.destroy_instance(instance.id)
  end

  it 'must allow to reboot instance in running state' do
    instance = @driver.create_instance('ami-aecd60c7', :realm_id => 'us-east-1a', :hwp_id => 't1.micro')
    instance = instance.wait_for!(@driver, record_retries) { |i| i.is_running? }
    instance.must_be_kind_of Instance
    instance.is_running?.must_equal true
    @driver.reboot_instance(instance.id)
    @driver.instance(:id => instance.id).state.must_equal 'RUNNING'
    @driver.destroy_instance(instance.id)
    instance.wait_for!(@driver, record_retries('stopped')) { |i| i.is_stopped? }
  end

end
