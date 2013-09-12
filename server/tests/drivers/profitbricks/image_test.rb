require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'Profitbricks data conversions' do

  before do
    Deltacloud::Drivers::Profitbricks::ProfitbricksDriver.send(:public, *Deltacloud::Drivers::Profitbricks::ProfitbricksDriver.private_instance_methods)
    @driver = Deltacloud::new(:profitbricks, credentials)
    @credentials = MiniTest::Mock.new
    @credentials.expect(:user, 'test')
    @credentials.expect(:password, 'test')
  end

  it "must find all images" do
    @credentials.expect(:user, 'test')
    image1 = ::Profitbricks::Image.new(:id => '1234a', :name => 'test1', :type => 'CDROM', cpu_hotpluggable: true, :region => 'EUROPE', :os_type => 'linux')
    image2 = ::Profitbricks::Image.new(:id => '567a', :name => 'test1', :type => 'HDD', cpu_hotpluggable: true, :region => 'EUROPE', :os_type => 'linux')
    ::Profitbricks::Image.stub(:all, [image1, image2]) do
      images = @driver.backend.images(@credentials)
      images.length.must_equal 1
      images[0].id.must_equal '567a'
      images[0].name.must_equal 'test1'
    end
  end
end
