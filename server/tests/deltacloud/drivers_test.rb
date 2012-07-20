require 'minitest/autorun'
require_relative 'common.rb'

describe Deltacloud::Drivers do

  it 'must provider access to all drivers configuration' do
    Deltacloud::Drivers.must_respond_to :driver_config
    Deltacloud::Drivers.driver_config.must_be_kind_of Hash
    Deltacloud::Drivers.driver_config.keys.must_include :mock
    Deltacloud::Drivers.driver_config[:mock][:name].wont_be_nil
    Deltacloud::Drivers.driver_config[:mock][:name].must_equal 'Mock'
  end

  it 'must provide list of entrypoints for some drivers' do
    Deltacloud::Drivers.driver_config[:ec2].wont_be_nil
    Deltacloud::Drivers.driver_config[:ec2][:entrypoints].must_be_kind_of Hash
  end

end

describe Deltacloud::Helpers::Drivers do

  before do
    class DriversHelper
      include Deltacloud::Helpers::Drivers
    end
    @helper = DriversHelper.new
  end

  it 'should report the current driver as a Symbol' do
    @helper.driver_symbol.wont_be_nil
    @helper.driver_symbol.must_be_kind_of Symbol
    @helper.driver_symbol.must_equal :mock
  end

  it 'should report the current driver name' do
    @helper.driver_name.wont_be_nil
    @helper.driver_name.must_be_kind_of String
    @helper.driver_name.must_equal 'mock'
  end

  it 'should provide the current driver class name' do
    @helper.driver_class_name.wont_be_nil
    @helper.driver_class_name.must_equal 'Mock'
  end

  it 'should provide the path to the current driver' do
    @helper.driver_source_name.wont_be_nil
    @helper.driver_source_name.must_equal '../drivers/mock/mock_driver.rb'
  end

  it 'should provide access to the driver instance' do
    @helper.driver_class.must_be_kind_of Deltacloud::Drivers::Mock::MockDriver
  end

  it 'should autoload the driver' do
    Thread.current[:driver] = 'ec2'
    @helper.driver.must_be_kind_of Deltacloud::Drivers::Ec2::Ec2Driver
    Thread.current[:driver] = 'mock'
  end

  it 'should throw an exception on unknown driver' do
    begin
      Thread.current[:driver] = 'unknown'
      Proc.new { @helper.driver }.must_raise RuntimeError
    ensure
      Thread.current[:driver] = 'mock'
    end
  end

end
