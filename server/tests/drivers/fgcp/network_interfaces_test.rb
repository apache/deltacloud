#$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'FgcpDriver NetworkInterfaces' do

  before do
    @driver = Deltacloud::new(:fgcp, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.network_interfaces(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of network_interfaces' do
    nics = @driver.network_interfaces
    nics.wont_be_empty
    nics.first.must_be_kind_of Deltacloud::NetworkInterface
  end

  it 'must allow to filter network_interfaces' do
    nic = @driver.network_interfaces(:id => 'UZXC0GRT-ZG8ZJCJ07-S-0547-NIC-0')
    nic.wont_be_nil
    nic.must_be_kind_of Array
    nic.size.must_equal 1
    nic.first.id.must_equal 'UZXC0GRT-ZG8ZJCJ07-S-0547-NIC-0'
    @driver.network_interfaces(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single network_interface' do
    nic = @driver.network_interface(:id => 'UZXC0GRT-ZG8ZJCJ07-S-0547-NIC-0')
    nic.wont_be_nil
    nic.must_be_kind_of Deltacloud::NetworkInterface
    nic.id.must_equal 'UZXC0GRT-ZG8ZJCJ07-S-0547-NIC-0'
    @driver.network_interface(:id => 'unknown').must_be_nil
  end

  it 'must have network' do
    nics = @driver.network_interfaces
    nics.wont_be_nil
    nics.must_be_kind_of Array
	nics.each do |nic|
	  nic.network.wont_be_empty
	end
  end

  it 'must have instance' do
    nics = @driver.network_interfaces
    nics.wont_be_nil
    nics.must_be_kind_of Array
	nics.each { |nic| nic.instance.wont_be_nil}
  end

  it 'must have ip address' do
    nics = @driver.network_interfaces
    nics.wont_be_nil
    nics.must_be_kind_of Array
	nics.each { |nic| nic.ip_address.wont_be_nil}
  end

end
