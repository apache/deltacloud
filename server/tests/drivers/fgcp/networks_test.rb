#$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'FgcpDriver Networks' do

  before do
    @driver = Deltacloud::new(:fgcp, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.networks(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of networks' do
    networks = @driver.networks
    networks.wont_be_empty
    networks.first.must_be_kind_of Deltacloud::Network
  end

  it 'must allow to filter networks' do
    network = @driver.networks(:id => 'UZXC0GRT-ZG8ZJCJ07-N')
    network.wont_be_nil
    network.must_be_kind_of Array
    network.size.must_equal 1
    network.first.id.must_equal 'UZXC0GRT-ZG8ZJCJ07-N'
    @driver.networks(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single network' do
    network = @driver.network(:id => 'UZXC0GRT-ZG8ZJCJ07-N')
    network.wont_be_nil
    network.must_be_kind_of Deltacloud::Network
    network.id.must_equal 'UZXC0GRT-ZG8ZJCJ07-N'
    @driver.network(:id => 'unknown').must_be_nil
  end

  it 'must be starter' do
    networks = @driver.networks
    networks.wont_be_empty
	networks.each { |network| network.state.must_equal 'UP'}
  end

  it 'must have subnets' do
    networks = @driver.networks
    networks.wont_be_empty
	networks.each { |network| network.subnets.wont_be_empty}
  end

  it 'must have address blocks' do
    networks = @driver.networks
    networks.wont_be_empty
    networks.must_be_kind_of Array
	networks.each do |network|
	  network.address_blocks.wont_be_empty
	  network.address_blocks.must_be_kind_of Array
	end
  end

end
