require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

require 'sinatra/base'
require 'sinatra/rabbit'

describe Deltacloud::HardwareProfile do

  before do
    @profile1 = Deltacloud::HardwareProfile.new('p1') do |hwp|
      cpu           1
      memory        512
      storage       100
      architecture 'i386'
    end
    @profile2 = Deltacloud::HardwareProfile.new('p2') do |hwp|
      cpu           1..10
      memory        [512, 1024]
    end
  end

  it 'should return proper unit for property' do
    Deltacloud::HardwareProfile.unit(:cpu).must_equal 'count'
    Deltacloud::HardwareProfile.unit(:storage).must_equal 'GB'
    Deltacloud::HardwareProfile.unit(:memory).must_equal 'MB'
    Deltacloud::HardwareProfile.unit(:architecture).must_equal 'label'
  end

  it 'should properly advertise the properties' do
    @profile1.properties.wont_be_empty
    @profile1.property(:cpu).must_be_kind_of Deltacloud::HardwareProfile::Property
    @profile1.property(:cpu).name.must_equal :cpu
  end

  it 'should return the default value for given property' do
    @profile1.default?(:cpu, '1').must_equal true
    @profile1.default?(:cpu, '666').must_equal false
  end

  it 'should return if given value is within property range' do
    @profile2.include?(:cpu, 5).must_equal true
    @profile2.include?(:cpu, 100).must_equal false
    @profile2.include?(:memory, 10).must_equal false
    @profile2.include?(:memory, 1024).must_equal true
  end

  it 'should return query params' do
    @profile1.params.wont_be_empty
  end

end
