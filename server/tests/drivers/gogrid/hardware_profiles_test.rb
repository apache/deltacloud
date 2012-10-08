require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'GoGrid Hardware Profiles' do

  before do
    @driver = Deltacloud::new(:gogrid, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.realms(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of hardware profiles' do
    @driver.hardware_profiles.wont_be_empty
    @driver.hardware_profiles.first.must_be_kind_of Deltacloud::HardwareProfile
  end

  it 'must allow to filter hardware profiles' do
    @driver.hardware_profiles(:id => 'web-server').wont_be_empty
    @driver.hardware_profiles(:id => 'web-server').must_be_kind_of Array
    @driver.hardware_profiles(:id => 'web-server').size.must_equal 1
    @driver.hardware_profiles(:id => 'web-server').first.name.must_equal 'web-server'
    @driver.hardware_profiles(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single hardware_profile' do
    profile = @driver.hardware_profile(:id => 'database-server')
    profile.wont_be_nil
    profile.must_be_kind_of Deltacloud::HardwareProfile
    profile.name.must_equal 'database-server'
    profile.properties.must_be_kind_of Array
    profile.properties.wont_be_empty
    profile.properties.each do |p|
      p.must_be_kind_of Deltacloud::HardwareProfile::Property
      p.name.to_s.wont_be_empty
      p.kind.to_s.wont_be_empty
    end
    @driver.hardware_profile(:id => 'unknown').must_be_nil
  end

end
