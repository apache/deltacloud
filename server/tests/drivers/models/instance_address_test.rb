require 'minitest/autorun'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'models', 'base_model.rb')
require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'models', 'instance_address.rb')

describe InstanceAddress do

  before do
    @address = InstanceAddress.new('192.168.0.1')
  end

  it 'should properly report address type' do
    @address.address_type.must_equal :ipv4
    @address.address.must_equal '192.168.0.1'
    @address.is_ipv4?.must_equal true
    InstanceAddress.new('01:23:45:67:89:ab', :type => :mac).address_type.must_equal :mac
    InstanceAddress.new('01:23:45:67:89:ab', :type => :mac).is_mac?.must_equal true
    InstanceAddress.new('test.local', :type => :hostname).is_hostname?.must_equal true
    InstanceAddress.new('test.local', :port => '5000', :type => :vnc).is_vnc?.must_equal true
    InstanceAddress.new('test.local', :port => '5000', :type => :vnc).port.must_equal '5000'
    InstanceAddress.new('test.local', :port => '5000', :type => :vnc).to_s.must_equal 'VNC:test.local:5000'
  end

end
