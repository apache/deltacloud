require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'Profitbricks storage volumes' do

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
    @credentials = MiniTest::Mock.new
    @credentials.expect(:user, 'test')
    @credentials.expect(:password, 'test')
  end
  describe "finding and creating storage volumnes" do

    it "must find all storage volumnes" do
      datacenter = MiniTest::Mock.new
      datacenter.expect(:storages, [@storage])
      ::Profitbricks::DataCenter.stub(:all, [datacenter]) do
        @driver.backend.storage_volumes(@credentials)
      end
    end
    it "must find a storage by id" do
      ::Profitbricks::Storage.stub(:find, @storage) do
        @driver.backend.storage_volumes(@credentials, :id => '1234a')
      end
    end
    it "must create a storage volume" do
      ::Profitbricks::Storage.stub(:create, @storage) do
        @driver.backend.create_storage_volume(@credentials, :capacity => 10, :name => 'test')
      end
    end
    it "must destroy a storage volume" do
      ::Profitbricks::Storage.stub(:find, @storage) do
        ::Profitbricks.stub(:request, true) do
         @driver.backend.destroy_storage_volume(@credentials)
       end
      end
    end
    it "must attach a storage volume" do
      storage = MiniTest::Mock.new
      storage.expect(:connect, true, [{:server_id => '567a'}]) 
      ::Profitbricks::Storage.stub(:find, storage) do
        @driver.backend.attach_storage_volume(@credentials, :id => '1234a', :instance_id => '567a')     
      end
    end
    it "must detach a storage volume" do
      storage = MiniTest::Mock.new
      storage.expect(:disconnect, true, [{:server_id => '567a'}]) 
      ::Profitbricks::Storage.stub(:find, storage) do
        @driver.backend.detach_storage_volume(@credentials, :id => '1234a', :instance_id => '567a')     
      end
    end
  end
end
