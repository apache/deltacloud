require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'Profitbricks networks' do

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
                                          :data_center_id => '1234a',
                                          :ip => '127.0.0.1')
    @nic = ::Profitbricks::Nic.new(:id => '1234a',
                                   :name => 'test',
                                   :server_id => 'server-id',
                                   :lan_id => 1,
                                   :firewall => {},
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
    @credentials = MiniTest::Mock.new
    @credentials.expect(:user, 'test')
    @credentials.expect(:password, 'test')
  end
  
  it "must get all network interfaces" do
    server = MiniTest::Mock.new
    server.expect(:nics, [@nic])
    server.expect(:nics, [@nic])
    ::Profitbricks::Server.stub(:all,[server]) do
      nic = @driver.backend.network_interfaces(@credentials)
      nic.class.must_equal Array
      nic[0].id.must_equal '1234a'
      nic[0].instance.must_equal 'server-id'
    end
  end
  
  it "must create a network interface" do
    ::Profitbricks::Nic.stub(:create, @nic) do
      nic = @driver.backend.create_network_interface(@credentials, :server_id => '!234a')
      nic.class.must_equal Deltacloud::NetworkInterface
      nic.id.must_equal '1234a'
    end
  end

  it "must destroy a network interface" do
    ::Profitbricks::Nic.stub(:find, @nic) do
      ::Profitbricks.stub(:request, true) do
        @driver.backend.destroy_network_interface(@credentials, :id => '!234a')
      end
    end
  end

  it "must find all networks" do
    server = MiniTest::Mock.new
    server.expect(:nics, [@nic])
    server.expect(:nics, [@nic])
    server.expect(:data_center_id, ['4567a'])
    ::Profitbricks::Server.stub(:all,[server]) do
      networks = @driver.backend.networks(@credentials)
      networks[0].class.must_equal Deltacloud::Network
      networks[0].id.must_equal 1
    end
  end

end
