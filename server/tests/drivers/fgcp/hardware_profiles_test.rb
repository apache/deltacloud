require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'FgcpDriver HardwareProfiles' do

  before do
    @driver = Deltacloud::new(:fgcp, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.hardware_profiles(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of hardware_profiles' do
    hardware_profiles = @driver.hardware_profiles
    hardware_profiles.wont_be_empty
    hardware_profiles.first.must_be_kind_of Deltacloud::HardwareProfile
  end

  it 'must allow to filter hardware_profiles' do
    hardware_profiles = @driver.hardware_profiles :id => 'economy'
    hardware_profiles.wont_be_empty
    hardware_profiles.must_be_kind_of Array
    hardware_profiles.size.must_equal 1
    hardware_profiles.first.id.must_equal 'economy'
    @driver.hardware_profiles(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single hardware_profile' do
    hardware_profile = @driver.hardware_profile :id => 'economy'
    hardware_profile.wont_be_nil
    hardware_profile.id.must_equal 'economy'
    hardware_profile.properties.must_be_kind_of Array
    hardware_profile.properties.wont_be_empty
    @driver.hardware_profile(:id => 'unknown').must_be_nil
  end

  it 'must include correct attributes' do
    hardware_profile = @driver.hardware_profiles.first
    hardware_profile.cpu.wont_be_nil
    hardware_profile.cpu.value.wont_be :<, 1
    hardware_profile.memory.wont_be_nil
    hardware_profile.memory.value.wont_be :<=, 1740 #1740.8 is lowest (economy)
    hardware_profile.storage.must_be_nil
  end

  it 'must include at least four profiles' do
    hardware_profiles = @driver.hardware_profiles
    hardware_profiles.size.wont_be :<, 4
  end

end
