require 'minitest/autorun'

load File.join(File.dirname(__FILE__), 'common.rb')

describe Deltacloud::Collections::Base do

  before do
    @base = Deltacloud::Collections::Base
  end

  it 'has config set correctly' do
    @base.config.must_be_kind_of Deltacloud::Server
    @base.config.root_url.must_equal Deltacloud.config[:deltacloud].root_url
  end

  it 'has root_url set correctly' do
    @base.root_url.must_equal  Deltacloud.config[:deltacloud].root_url
  end

  it 'has version set correctly' do
    @base.version.must_equal  Deltacloud.config[:deltacloud].version
  end

  it 'provides helper for routes' do
    @base.must_respond_to :route_for
    @base.route_for('/hardware_profiles').must_equal "#{Deltacloud.config[:deltacloud].root_url}/hardware_profiles"
  end

end
