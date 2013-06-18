require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'MockDriver Instances' do

  before do
    @driver = Deltacloud::new(:mock, :user => 'mockuser', :password => 'mockpassword')
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.instances(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of instances' do
    @driver.instances.wont_be_empty
    @driver.instances.first.must_be_kind_of Deltacloud::Instance
  end

  it 'must allow to filter instances' do
    @driver.instances(:id => 'inst1').wont_be_empty
    @driver.instances(:id => 'inst1').must_be_kind_of Array
    @driver.instances(:id => 'inst1').size.must_equal 1
    @driver.instances(:id => 'inst1').first.id.must_equal 'inst1'
    @driver.instances(:owner_id => 'mockuser').size.must_equal 4
    @driver.instances(:owner_id => 'mockuser').first.owner_id.must_equal 'mockuser'
    @driver.instances(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single instance' do
    @driver.instance(:id => 'inst1').wont_be_nil
    @driver.instance(:id => 'inst1').must_be_kind_of Deltacloud::Instance
    @driver.instance(:id => 'inst1').id.must_equal 'inst1'
    @driver.instance(:id => 'unknown').must_be_nil
  end

  it 'must allow to create a new instance if instance supported' do
    instance = @driver.create_instance('img1', :name => 'inst1-test', :realm_id => 'us', :hwp_id => 'm1-small')
    instance.must_be_kind_of Deltacloud::Instance
    @driver.instance(:id => instance.id).wont_be_nil
    @driver.instance(:id => instance.id).id.must_equal instance.id
    @driver.instance(:id => instance.id).name.must_equal 'inst1-test'
    @driver.instance(:id => instance.id).instance_profile.name.must_equal 'm1-small'
    @driver.instance(:id => instance.id).realm_id.must_equal 'us'
    @driver.instance(:id => instance.id).owner_id.must_equal 'mockuser'
    @driver.instance(:id => instance.id).state.must_equal 'RUNNING'
    @driver.instance(:id => instance.id).public_addresses.wont_be_empty
    @driver.instance(:id => instance.id).actions.must_include :reboot
    @driver.instance(:id => instance.id).actions.must_include :stop
    @driver.destroy_instance(instance.id)
    @driver.instance(:id => instance.id).must_be_nil
  end

  it 'must respond with proper error when using unknown hardware profile' do
    Proc.new {
      @driver.create_instance('img1', :name => 'inst2-test', :realm_id => 'us', :hwp_id => 'unknown')
    }.must_raise Deltacloud::Exceptions::ValidationFailure
  end

  it 'must allow to destroy created instance' do
    instance = @driver.create_instance('img1', :name => 'inst1-test-destroy')
    instance.must_be_kind_of Deltacloud::Instance
    @driver.destroy_instance(instance.id)
    @driver.instance(:id => instance.id).must_be_nil
  end

  it 'must allow to stop instance in running state' do
    instance = @driver.create_instance('img1', :name => 'inst1-test-destroy')
    instance.must_be_kind_of Deltacloud::Instance
    instance.state.must_equal 'RUNNING'
    @driver.stop_instance(instance.id)
    @driver.instance(:id => instance.id).state.must_equal 'STOPPED'
    @driver.destroy_instance(instance.id)
    @driver.instance(:id => instance.id).must_be_nil
  end

  it 'must allow to start instance in stopped state' do
    instance = @driver.create_instance('img1', :name => 'inst1-test-destroy')
    instance.must_be_kind_of Deltacloud::Instance
    instance.state.must_equal 'RUNNING'
    @driver.stop_instance(instance.id)
    @driver.instance(:id => instance.id).state.must_equal 'STOPPED'
    @driver.start_instance(instance.id)
    @driver.instance(:id => instance.id).state.must_equal 'RUNNING'
    @driver.destroy_instance(instance.id)
    @driver.instance(:id => instance.id).must_be_nil
  end

  it 'must allow to reboot instance in running state' do
    instance = @driver.create_instance('img1', :name => 'inst1-test-destroy')
    instance.must_be_kind_of Deltacloud::Instance
    instance.state.must_equal 'RUNNING'
    @driver.reboot_instance(instance.id)
    @driver.instance(:id => instance.id).state.must_equal 'RUNNING'
    @driver.stop_instance(instance.id)
    @driver.instance(:id => instance.id).state.must_equal 'STOPPED'
    @driver.reboot_instance(instance.id)
    @driver.instance(:id => instance.id).state.must_equal 'RUNNING'
    @driver.destroy_instance(instance.id)
    @driver.instance(:id => instance.id).must_be_nil
  end

  it 'must support run_on_instance' do
    run_cmd = @driver.run_on_instance(:cmd => 'uname', :port => '22', :private_key => '123', :ip => '127.0.0.1')
    run_cmd.body.must_equal "This is where the output from 'uname' would appear if this were not a mock provider"
    run_cmd.ssh.must_be_kind_of Deltacloud::Drivers::Mock::MockDriver::MockSSH
    run_cmd.ssh.command.must_equal 'uname'
  end

end
