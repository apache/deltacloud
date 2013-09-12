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
    @lb = ::Profitbricks::LoadBalancer.new(:id => '5678a',
                                          :name => 'test',
                                          :creation_time => Time.now,
                                          :data_center_id => '1234a',
                                          :ip => '127.0.0.1')
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

  it "must find a load balancer" do
    ::Profitbricks::LoadBalancer.stub(:find, @lb) do
      ::Profitbricks::DataCenter.stub(:find, @dc) do
        @driver.backend.load_balancer(@credentials, :id => '1234a')
      end
    end
  end

  it "must find all load balancer" do
    datacenter = MiniTest::Mock.new
    datacenter.expect(:id, '1234a')
    datacenter.expect(:name, 'test')
    datacenter.expect(:load_balancers, [@lb])
    datacenter.expect(:region, 'EUROPE')
    ::Profitbricks::DataCenter.stub(:all, [datacenter]) do
      @driver.backend.load_balancers(@credentials)
    end
  end

  it "must create a load balancer" do
    ::Profitbricks::LoadBalancer.stub(:create, @lb) do
      @driver.backend.stub(:load_balancer, true) do
        @driver.backend.create_load_balancer(@credentials, :name => 'test')
      end
    end
  end

  it "must register an instance" do
    lb = MiniTest::Mock.new
    lb.expect(:register_servers, true, [[@server]])
    ::Profitbricks::LoadBalancer.stub(:find, lb) do
      ::Profitbricks::Server.stub(:find, @server) do
        @driver.backend.stub(:load_balancer, true) do
          @driver.backend.lb_register_instance(@credentials)
        end
      end
    end
  end

  it "must unregister an instance" do
    lb = MiniTest::Mock.new
    lb.expect(:deregister_servers, true, [[@server]])
    ::Profitbricks::LoadBalancer.stub(:find, lb) do
      ::Profitbricks::Server.stub(:find, @server) do
        @driver.backend.stub(:load_balancer, true) do
          @driver.backend.lb_unregister_instance(@credentials)
        end
      end
    end
  end

  it "must be deletable" do
    ::Profitbricks::LoadBalancer.stub(:find, @lb) do
      ::Profitbricks.stub(:request, :true) do
        @driver.backend.destroy_load_balancer(@credentials, '1234a') 
      end
    end
  end
end
