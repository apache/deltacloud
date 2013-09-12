require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'Profitbricks data conversions' do

  before do
    Deltacloud::Drivers::Profitbricks::ProfitbricksDriver.send(:public, *Deltacloud::Drivers::Profitbricks::ProfitbricksDriver.private_instance_methods)
    @driver = Deltacloud::new(:profitbricks, credentials)
    @storage = ::Profitbricks::Storage.new(:id => '1234a',
                                          :name => 'test',
                                          :provisioning_state => 'INPROCESS',
                                          :size => 20,
                                          :data_center_id => '4321',
                                          :creation_time => Time.now,
                                          :server_ids => ['5678'],
                                          :mount_image => {:id => '5678a'})

    @server = MiniTest::Mock.new
    @credentials = MiniTest::Mock.new
    @credentials.expect(:user, 'test')
    @credentials.expect(:password, 'test')
  end
  describe "finding and creating instances" do
    before do
      @server.expect(:id, '1234a')
      @server.expect(:data_center_id, '5678a')
      @server.expect(:name, 'text')
      @server.expect(:name, 'text')
      @server.expect(:connected_storages, nil)
      @server.expect(:connected_storages, nil)
      @server.expect(:public_ips, ['127.0.0.1'])
      @server.expect(:private_ips, ['127.0.0.1'])
    end

    it "must find all instances" do
      @credentials.expect(:user, 'test')
      ::Profitbricks::Server.stub(:all, [@server]) do
        @driver.backend.instances(@credentials)
      end
    end

    it "must find all instances of the same datacenter as the given storage_id" do
      @credentials.expect(:user, 'test')
      datacenter = MiniTest::Mock.new
      datacenter.expect(:servers, [@server])
      ::Profitbricks::Storage.stub(:find, @storage) do
        ::Profitbricks::DataCenter.stub(:find, datacenter) do
          @driver.backend.instances(@credentials, :storage_id => '1234a')
        end
      end
    end
    it "must create an instacne" do
      @credentials.expect(:user, 'test')
      ::Profitbricks::Storage.stub(:create, @storage) do
        ::Profitbricks::Server.stub(:create, @server) do
          @driver.backend.create_instance(@credentials, '1234a', :name => 'test', :hwp_storage => 20)
        end
      end
    end

  end
  it "must be rebooted" do
    @server.expect(:reset, true)
    ::Profitbricks::Server.stub(:find, @server) do
      @driver.backend.reboot_instance(@credentials, '1234a')
    end
    @server.verify
  end

  it "must be stopped" do
    @server.expect(:stop, true)
    ::Profitbricks::Server.stub(:find, @server) do
      @driver.backend.stop_instance(@credentials, '1234a')
    end
    @server.verify
  end

  it "must be started" do
    @server.expect(:start, true)
    ::Profitbricks::Server.stub(:find, @server) do
      @driver.backend.start_instance(@credentials, '1234a')
    end
    @server.verify
  end

  it "must be destroyed" do
    server = ::Profitbricks::Server.new :id => '1234a'
    ::Profitbricks::Server.stub(:find, server) do
      ::Profitbricks.stub(:request, true) do
        @driver.backend.destroy_instance(@credentials, '1234a')
      end
    end
    
  end
end
