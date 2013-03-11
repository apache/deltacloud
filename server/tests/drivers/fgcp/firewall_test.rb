#$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'FgcpDriver Firewalls' do

  before do
    @driver = Deltacloud::new(:fgcp, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.firewalls(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of firewalls' do
    fws = @driver.firewalls
    fws.wont_be_empty
    fws.each { |fw| fw.must_be_kind_of Firewall }
    fws.each { |fw| fw.id.wont_be_nil }
  end

  it 'must allow to filter firewalls' do
    fw = @driver.firewalls(:id => 'UZXC0GRT-ZG8ZJCJ07-S-0001')
    fw.wont_be_empty
    fw.must_be_kind_of Array
    fw.size.must_equal 1
    fw.first.id.must_equal 'UZXC0GRT-ZG8ZJCJ07-S-0001'
    @driver.firewalls(:id => 'UZXC0GRT-ZG8ZJCJ07-S-0000').must_be_empty
  end

  it 'must allow to retrieve single firewall' do
    fw = @driver.firewall(:id => 'UZXC0GRT-ZG8ZJCJ07-S-0001')
    fw.wont_be_nil
    fw.must_be_kind_of Firewall
    fw.id.must_equal 'UZXC0GRT-ZG8ZJCJ07-S-0001'
    @driver.firewall(:id => 'UZXC0GRT-ZG8ZJCJ07-S-0000').must_be_nil
  end

  it 'must describe single firewall' do
    fw = @driver.firewall(:id => 'UZXC0GRT-ZG8ZJCJ07-S-0001')
    fw.wont_be_nil
    fw.id.must_equal 'UZXC0GRT-ZG8ZJCJ07-S-0001'
    fw.name.must_equal 'Firewall'
    fw.owner_id.wont_be_nil
    fw.description.wont_be_nil
  end

  it 'must list firewall rules' do
    fw = @driver.firewall(:id => 'UZXC0GRT-ZG8ZJCJ07-S-0001')
    fw.wont_be_nil
    fw.rules.wont_be_empty
    fw.rules.first.must_be_kind_of FirewallRule
    fw.rules.first.allow_protocol.wont_be_nil
    fw.rules.first.port_from.wont_be_nil
    fw.rules.first.port_to.wont_be_nil
    fw.rules.first.direction.wont_be_nil
    fw.rules.first.rule_action.wont_be_nil
    fw.rules.first.log_rule.wont_be_nil
    fw.rules.first.sources.wont_be_empty
  end

end
