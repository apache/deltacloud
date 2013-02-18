require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'FgcpDriver Providers' do

  before do
    @driver = Deltacloud::new(:fgcp, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must support listing of available providers' do
    providers = @driver.providers
    providers.wont_be_empty
    providers.each { |p| p.must_be_kind_of Provider }
    providers.each { |p| p.name.wont_be_empty }
    providers.each { |p| p.url.wont_be_empty }
    providers.each { |p| p.id.wont_be_empty }
    providers.each { |p| ['fgcp-au', 'fgcp-sg', 'fgcp-uk', 'fgcp-us', 'fgcp-de', 'fgcp-jp-east', 'fgcp-jp-west'].must_include p.id }
  end

end
