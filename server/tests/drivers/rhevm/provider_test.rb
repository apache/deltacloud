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
    }.must_raise Deltacloud::ExceptionHandler::BackendError
  end

  it 'must support listing of available providers' do
    @driver.providers.wont_be_empty
    @driver.providers.each { |p| p.must_be_kind_of Provider }
    @driver.providers.each { |p| p.name.wont_be_empty }
    @driver.providers.each { |p| p.id.wont_be_empty }
    @driver.providers.each { |p| p.url.wont_be_empty }
  end

  it 'must switch realms when switching between different clusters' do

    provider1 = @driver.provider(:id => 'aa585157-a098-48c3-8b5b-70a32e88c263')
    provider1.wont_be_nil
    provider1.url.wont_be_empty

    provider2 = @driver.provider(:id => '645e425e-66fe-4ac9-8874-537bd10ef08d')
    provider2.wont_be_nil
    provider2.url.wont_be_empty

    drv1 = Deltacloud::new(:rhevm, credentials.merge(:provider => provider1.url))
    drv2 = Deltacloud::new(:rhevm, credentials.merge(:provider => provider2.url))

    drv1.realms.map { |r| r.id }.wont_include drv2.realms.map { |r| r.id }
  end

end
