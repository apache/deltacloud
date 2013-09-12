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
    @credentials = MiniTest::Mock.new
    @credentials.expect(:user, 'test')
    @credentials.expect(:password, 'test')
  end

  it "must find all realms" do
    @credentials.expect(:user, 'test')
    ::Profitbricks::DataCenter.stub(:all, [@dc]) do
      dcs = @driver.backend.realms(@credentials)
      dcs.length.must_equal 1
      dcs[0].id.must_equal '1234a'
      dcs[0].name.must_equal 'test (EUROPE)'
    end
  end

  it "must find realms of the same region as the given image" do
    @credentials.expect(:user, 'test')
    dc2 = ::Profitbricks::DataCenter.new(:id => '567a', :region => 'US')
    ::Profitbricks::DataCenter.stub(:all, [@dc, dc2]) do
      dcs = @driver.backend.realms(@credentials, :image => OpenStruct.new(:description => 'Region: (EUROPE),'))
      dcs.length.must_equal 1
      dcs[0].id.must_equal '1234a'
      dcs[0].name.must_equal 'test (EUROPE)'
    end
  end
end
