require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe Deltacloud::Helpers::Application do

  before do
    class ApplicationHelper
      include Deltacloud::Helpers::Drivers
      include Deltacloud::Helpers::Application
    end
    @helper = ApplicationHelper.new
  end

  it 'provides name for the authentication feature' do
    @helper.auth_feature_name.wont_be_nil
    @helper.auth_feature_name.must_equal 'key'
    Thread.current[:driver] = 'gogrid'
    @helper.auth_feature_name.must_equal 'password'
    Thread.current[:driver] = 'mock'
  end

  it 'provides HTTP methods for instance actions' do
    @helper.instance_action_method(:stop).wont_be_nil
    @helper.instance_action_method(:stop).must_equal :post
    @helper.instance_action_method(:destroy).must_equal :delete
  end

  it 'provide helper for wrapping text nodes with CDATA' do
    @helper.render_cdata('test').must_equal '<![CDATA[test]]>'
    @helper.render_cdata('').must_equal '<![CDATA[]]>'
    @helper.render_cdata('test   ').must_equal '<![CDATA[test]]>'
    @helper.render_cdata(nil).must_be_nil
  end

  it 'provide helper to access driver entrypoints' do
    @helper.driver_provider(Deltacloud::Drivers.driver_config[:ec2]).must_be_kind_of Hash
    @helper.driver_provider(Deltacloud::Drivers.driver_config[:ec2]).keys.wont_be_empty
  end

end
