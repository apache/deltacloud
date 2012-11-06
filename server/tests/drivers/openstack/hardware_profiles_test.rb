require 'minitest/autorun'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'api.rb')
require_relative 'common.rb'

describe 'OpenStackDriver HardwareProfiles' do

  before do
    @driver = Deltacloud::new(:openstack, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.images(OpenStruct.new(:user => 'unknown+wrong', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of hardware_profiles' do
    @driver.hardware_profiles.wont_be_empty
    @driver.hardware_profiles.first.must_be_kind_of Deltacloud::HardwareProfile
  end

  it 'must allow to filter hardware_profiles' do
    hardware_profiles = @driver.hardware_profiles :id => '1'
    hardware_profiles.wont_be_empty
    hardware_profiles.must_be_kind_of Array
    hardware_profiles.size.must_equal 1
    hardware_profiles.first.id.must_equal '1'
    @driver.hardware_profiles(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single hardware_profile' do
    hardware_profile = @driver.hardware_profile :id => '1'
    hardware_profile.wont_be_nil
    hardware_profile.id.must_equal '1'
    hardware_profile.properties.must_be_kind_of Array
    hardware_profile.properties.wont_be_empty
    @driver.hardware_profile(:id => 'unknown').must_be_nil
  end

end
