require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'RHEV-M provider test' do

  before do
    @config = Deltacloud::Test::config
    @driver = @config.driver(:rhevm)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when using wrong provider' do
    creds = @config.credentials(:rhevm).merge(:provider => 'unknown')
    creds[:provider] = 'unknown'
    wrong_driver = Deltacloud::new(:rhevm, creds)
    Proc.new {
      wrong_driver.realms
    }.must_raise Deltacloud::Exceptions::BackendError
  end

  it 'must support listing of available providers' do
    @driver.providers.wont_be_empty
    @driver.providers.each { |p| p.must_be_kind_of Deltacloud::Provider }
    @driver.providers.each { |p| p.name.wont_be_empty }
    @driver.providers.each { |p| p.id.wont_be_empty }
    @driver.providers.each { |p| p.url.wont_be_empty }
  end

  it 'must switch realms when switching between different clusters' do
    provs = @driver.providers
    if provs.size < 2
      skip "We need at least two providers (clusters)"
    end
    provider1 = provs[0]
    provider1.wont_be_nil
    provider1.url.wont_be_empty

    provider2 = provs[1]
    provider2.wont_be_nil
    provider2.url.wont_be_empty

    drv1 = Deltacloud::new(:rhevm, credentials.merge(:provider => provider1.url))
    drv2 = Deltacloud::new(:rhevm, credentials.merge(:provider => provider2.url))

    drv1.realms.map { |r| r.id }.wont_include drv2.realms.map { |r| r.id }
  end

end
