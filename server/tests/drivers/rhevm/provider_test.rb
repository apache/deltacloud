require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'RHEV-M provider test' do

  before do
    @driver = Deltacloud::new(:rhevm, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when using wrong provider' do
    wrong_driver = Deltacloud::new(:rhevm, credentials.merge(:provider => 'unknown'))
    Proc.new {
      wrong_driver.realms
    }.must_raise Deltacloud::Exceptions::BackendError
  end

  it 'must support listing of available providers' do
    @driver.providers.wont_be_empty
    @driver.providers.each { |p| p.must_be_kind_of Provider }
    @driver.providers.each { |p| p.name.wont_be_empty }
    @driver.providers.each { |p| p.id.wont_be_empty }
    @driver.providers.each { |p| p.url.wont_be_empty }
  end

  it 'must switch realms when switching between different clusters' do

    provider1 = @driver.provider(:id => '9df72b84-0234-11e2-9b87-9386d9b09d4a')
    provider1.wont_be_nil
    provider1.url.wont_be_empty

    provider2 = @driver.provider(:id => '9df72b84-0234-11e2-9b87-9386d9b09d4a')
    provider2.wont_be_nil
    provider2.url.wont_be_empty

    drv1 = Deltacloud::new(:rhevm, credentials.merge(:provider => provider1.url))
    drv2 = Deltacloud::new(:rhevm, credentials.merge(:provider => provider2.url))

    drv1.realms.map { |r| r.id }.wont_include drv2.realms.map { |r| r.id }
  end

end
