#$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'FgcpDriver Subnets' do

  before do
    @driver = Deltacloud::new(:fgcp, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.subnets(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of subnets' do
    subnets = @driver.subnets
    subnets.wont_be_empty
    subnets.first.must_be_kind_of Deltacloud::Subnet
  end

  it 'must allow to filter subnets' do
    subnet = @driver.subnets(:id => 'UZXC0GRT-ZG8ZJCJ07-N-DMZ')
    subnet.wont_be_nil
    subnet.must_be_kind_of Array
    subnet.size.must_equal 1
    subnet.first.id.must_equal 'UZXC0GRT-ZG8ZJCJ07-N-DMZ'
    @driver.subnets(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single subnet' do
    subnet = @driver.subnet(:id => 'UZXC0GRT-ZG8ZJCJ07-N-DMZ')
    subnet.wont_be_nil
    subnet.must_be_kind_of Deltacloud::Subnet
    subnet.id.must_equal 'UZXC0GRT-ZG8ZJCJ07-N-DMZ'
    @driver.subnet(:id => 'unknown').must_be_nil
  end

  it 'must have network' do
    subnets = @driver.subnets
    subnets.wont_be_empty
    subnets.must_be_kind_of Array
	subnets.each { |subnet| subnet.network.wont_be_nil}
	subnets.each do |subnet|
	  subnet.network.wont_be_nil
	end
  end

  it 'must have address block' do
    subnets = @driver.subnets
    subnets.wont_be_empty
    subnets.must_be_kind_of Array
	subnets.each do |subnet|
	  subnet.address_block.wont_be_empty
	end
  end

end
