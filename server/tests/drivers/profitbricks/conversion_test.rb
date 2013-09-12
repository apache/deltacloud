require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'Profitbricks data conversions' do

  before do
    Deltacloud::Drivers::Profitbricks::ProfitbricksDriver.send(:public, *Deltacloud::Drivers::Profitbricks::ProfitbricksDriver.private_instance_methods)
    @driver = Deltacloud::new(:profitbricks, credentials)
    @dc = ::Profitbricks::DataCenter.new(:id => '1234a',
                                        :name => 'test',
                                        :region => 'EUROPE')
    #@image = ::Profitbricks::Image.new(:id => '5678a')
    @storage = ::Profitbricks::Storage.new(:id => '1234a',
                                          :name => 'test',
                                          :provisioning_state => 'INPROCESS',
                                          :size => 20,
                                          :data_center_id => '4321',
                                          :creation_time => Time.now,
                                          :server_ids => ['5678'],
                                          :mount_image => {:id => '5678a'})
    @lb = ::Profitbricks::LoadBalancer.new(:id => '5678a',
                                          :name => 'test',
                                          :creation_time => Time.now,
                                          :ip => '127.0.0.1')
    @nic = ::Profitbricks::Nic.new(:id => '1234a',
                                   :name => 'test',
                                   :server_id => 'server-id',
                                   :lan_id => 1,
                                   :ips => ['127.0.0.1'])
    @fwr = ::Profitbricks::FirewallRule.new(:id => '1234a',
                                            :protocol => 'TCP',
                                            :port_range_start => 80,
                                            :port_range_end => 81,
                                            :source_ip => '0.0.0.0')
    @fw = ::Profitbricks::Firewall.new(:id => '1234a',
                                       :nic_id => '5678a',
                                       :rules => [@fwr.attributes])
    @ip_block = ::Profitbricks::IpBlock.new(:ips => ['127.0.0.1'])
    @server = ::Profitbricks::Server.new(:id => '1234a',
                                         :data_center_id => 'data-center-id',
                                         :name => 'server',
                                         :virtual_machine_state => 'INPROCESS',
                                         :private_ips => nil,
                                         :public_ips => ['127.0.0.1'],
                                         :provisioning_state => 'AVAILABLE',
                                         :connected_storages => {:id => 'storage'})
  end

  it "must convert an instance" do
    @driver.backend.stub(:find_instance_image, '5678a') do
      ::Profitbricks::Server.stub(:find, @server) do
        server = @driver.backend.convert_instance(@server, 'test')
        server.must_be_kind_of Deltacloud::Instance
        server.id.must_equal '1234a'
        server.name.must_equal 'server'
        server.image_id.must_equal '5678a'
        server.storage_volumes.must_equal [{'storage' => nil}]
      end
    end
  end

  it "must find the instance image" do
    ::Profitbricks::Storage.stub(:find, @storage) do
      @server.instance_variable_set(:@connected_storages, [@storage])
      storage_id = @driver.backend.find_instance_image(@server)
      storage_id.must_equal '5678a'
    end
  end

  it "must convert a storage volume" do
    s = @driver.backend.convert_storage(@storage)
    s.must_be_kind_of Deltacloud::StorageVolume
    s.id.must_equal '1234a'
    s.capacity.must_equal 20
    s.name.must_equal 'test'
    s.state.must_equal 'PENDING'
  end

  it "must convert a data center" do
    d = @driver.backend.convert_data_center(@dc)
    d.must_be_kind_of Deltacloud::Realm
    d.id.must_equal '1234a'
    d.name.must_equal 'test (EUROPE)'
  end

  it "must convert a load balancer" do
    l = @driver.backend.convert_load_balancer(@lb, @dc)
    l.must_be_kind_of Deltacloud::LoadBalancer
    l.id.must_equal '5678a'
    l.name.must_equal 'test'
    l.public_addresses.must_equal ['127.0.0.1']
    l.realms.must_be_kind_of Array
    l.realms[0].must_be_kind_of Deltacloud::Realm
  end

  it "must convert a network interface" do
    nic = @driver.backend.convert_network_interface(@nic)
    nic.must_be_kind_of Deltacloud::NetworkInterface
    nic.id.must_equal '1234a'
    nic.name.must_equal 'test'
    nic.instance.must_equal 'server-id'
    nic.network.must_equal 1
    nic.ip_address.must_equal '127.0.0.1'
  end

  it "must convert a firewall rule" do
    fwr = @driver.backend.convert_firewall_rule(@fwr)
    fwr.must_be_kind_of Deltacloud::FirewallRule
    fwr.id.must_equal '1234a'
    fwr.allow_protocol.must_equal 'TCP'
    fwr.port_from.must_equal 80
    fwr.port_to.must_equal 81
    fwr.sources.must_be_kind_of Array
    fwr.sources[0].must_equal({:type => 'address', :family => 'ipv4',
                               :address => '0.0.0.0', :prefix => ''})
    fwr.direction.must_equal 'ingress'
  end

  it "must convert a firewall" do
    fw = @driver.backend.convert_firewall(@fw)
    fw.must_be_kind_of Deltacloud::Firewall
    fw.id.must_equal '1234a'
    fw.description.must_equal 'Firewall of 5678a'
    fw.owner_id.must_equal '5678a'
    fw.rules.must_be_kind_of Array
    fw.rules[0].must_be_kind_of Deltacloud::FirewallRule
  end

  it "must convert a ip block" do
    adr = @driver.backend.convert_ip_block(@ip_block, [@server])
    adr.must_be_kind_of Deltacloud::Address
    adr.id.must_equal '127.0.0.1'
    adr.instance_id.must_equal '1234a'
  end

  it "must find an ip block by ip" do
    ::Profitbricks::IpBlock.stub(:all, [@ip_block]) do
      ip_block = @driver.backend.find_ip_block_by_ip('127.0.0.1')
      ip_block.must_be_kind_of ::Profitbricks::IpBlock
      ip_block.must_equal @ip_block
    end
  end
end
