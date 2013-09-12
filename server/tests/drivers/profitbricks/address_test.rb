require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'Profitbricks addresses' do

  before do
    Deltacloud::Drivers::Profitbricks::ProfitbricksDriver.send(:public, *Deltacloud::Drivers::Profitbricks::ProfitbricksDriver.private_instance_methods)
    @driver = Deltacloud::new(:profitbricks, credentials)

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

  it "must find all addresses" do
    ::Profitbricks::Server.stub(:all, [@server]) do
      ::Profitbricks::IpBlock.stub(:all, [@ip_block]) do
        addresses = @driver.backend.addresses(@credentials)
        addresses.class.must_equal Array
        addresses.length.must_equal 1
        addresses[0].id.must_equal '127.0.0.1'
        addresses[0].instance_id.must_equal '1234a'
      end
    end
  end

  it "must find an adress by id" do
    ::Profitbricks::Server.stub(:all, [@server]) do
      ::Profitbricks::IpBlock.stub(:all, [@ip_block]) do
        address = @driver.backend.address(@credentials, :id => '127.0.0.1')
        address.class.must_equal Deltacloud::Address
        address.id.must_equal '127.0.0.1'
        address.instance_id.must_equal '1234a'
      end
    end
  end
  
  it "muste create an address" do
    ::Profitbricks::IpBlock.stub(:reserve, @ip_block) do
      address = @driver.backend.create_address(@credentials)
      address.class.must_equal Deltacloud::Address
      address.id.must_equal '127.0.0.1'
      address.instance_id.must_equal nil
    end
  end

  it "must destroy an address" do
    ip_block = MiniTest::Mock.new
    ip_block.expect(:release, true)
    ip_block.expect(:ips, ['127.0.0.1'])
    ::Profitbricks::Server.stub(:all, [@server]) do
      ::Profitbricks::IpBlock.stub(:all, [ip_block]) do
        @driver.backend.destroy_address(@credentials,  :id => '127.0.0.1')
      end
    end
  end

  it "must associate an address" do
    nic = MiniTest::Mock.new
    nic.expect(:add_ip, true, ['127.0.0.1'])
    server = MiniTest::Mock.new
    server.expect(:nics, [nic])
    ::Profitbricks::Server.stub(:find, server) do
      ::Profitbricks::IpBlock.stub(:all, [@ip_block]) do
        address = @driver.backend.associate_address(@credentials,  :id => '127.0.0.1', :instance_id => '1234a')
        address.class.must_equal Deltacloud::Address
        address.id.must_equal '127.0.0.1'
        address.instance_id.must_equal nil
      end
    end
  end

  it "must associate an address" do
    nic = MiniTest::Mock.new
    nic.expect(:remove_ip, true, ['127.0.0.1'])
    server = MiniTest::Mock.new
    server.expect(:nics, [nic])
    server.expect(:public_ips, [['127.0.0.1']])
    ::Profitbricks::Server.stub(:all, [server]) do
      ::Profitbricks::Server.stub(:find, server) do
        ::Profitbricks::IpBlock.stub(:all, [@ip_block]) do
        address = @driver.backend.disassociate_address(@credentials,  :id => '127.0.0.1')
        address.class.must_equal Deltacloud::Address
        address.id.must_equal '127.0.0.1'
        address.instance_id.must_equal nil
      end
    end
    end
  end
end
