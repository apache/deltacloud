require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'GoGridDriver Instances' do

  INSTANCE_ID = "test-instance"

  before do
    @driver = Deltacloud::new(:gogrid, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  def self.create_test_instance
    driver = Deltacloud::new(:gogrid, credentials)
    VCR.use_cassette "instances_create_test_instance" do
      @@instance = driver.instance(:id => INSTANCE_ID)
      @@instance ||= driver.create_instance(fixed_image_id,
                                            :name=> INSTANCE_ID)
    end
  end

  # Destroy test instance when all test are done
  def self.__name__
    # record_retries below calls this
    "instances_test_class"
  end

  def self.destroy_test_instance
    driver = Deltacloud::new(:gogrid, credentials)

    # Go fast when running off a recording
    opts = record_retries('', :time_between_retry => 60)
    @@instance.wait_for!(driver, opts) do |i|
      i.actions.include?(:destroy)
    end

    VCR.use_cassette "instances_destroy_test_instance" do
      driver.destroy_instance(@@instance.id)
      @@instance = nil
    end
  end

  # Setup/teardown before/after all tests
  create_test_instance

  MiniTest::Unit::after_tests { destroy_test_instance }

  let :instance do
    @@instance
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.images(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::ExceptionHandler::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of instances' do
    @driver.instances.wont_be_empty
    @driver.instances.first.must_be_kind_of Instance
  end

  it 'must allow to filter instances' do
    by_id = @driver.instances(:id => instance.id)
    by_id.wont_be_empty
    by_id.must_be_kind_of Array
    by_id.size.must_equal 1
    by_id.first.id.must_equal instance.id

    by_owner = @driver.instances(:owner_id => instance.owner_id)
    by_owner.wont_be_empty
    by_owner.each do |inst|
      inst.owner_id.must_equal instance.owner_id
    end

    @driver.instances(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single instance' do
    by_id = @driver.instance(:id => instance.id)
    by_id.wont_be_nil
    by_id.must_be_kind_of Instance
    by_id.id.must_equal instance.id
    @driver.instance(:id => "unknown").must_be_nil
  end
end
