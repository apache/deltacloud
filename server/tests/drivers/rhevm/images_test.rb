require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'RhevmDriver Images' do

  before do
    @driver = Deltacloud::new(:rhevm, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.images(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::ExceptionHandler::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of images' do
    @driver.images.wont_be_empty
    @driver.images.first.must_be_kind_of Image
  end

  it 'must allow to filter images' do
    @driver.images(:id => 'dfa924b7-83e8-4a5c-9d5c-1270fd0c0872').wont_be_empty
    @driver.images(:id => 'dfa924b7-83e8-4a5c-9d5c-1270fd0c0872').must_be_kind_of Array
    @driver.images(:id => 'dfa924b7-83e8-4a5c-9d5c-1270fd0c0872').size.must_equal 1
    @driver.images(:id => 'dfa924b7-83e8-4a5c-9d5c-1270fd0c0872').first.id.must_equal 'dfa924b7-83e8-4a5c-9d5c-1270fd0c0872'
    @driver.images(:owner_id => 'vdcadmin@rhev.lab.eng.brq.redhat.com').each do |img|
      img.owner_id.must_equal 'vdcadmin@rhev.lab.eng.brq.redhat.com'
    end
    @driver.images(:id => 'ami-aaaaaaaa').must_be_empty
    @driver.images(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single image' do
    # NOTE: This test will cause VCR to fail due to wrong serialization
    # of YAML under Ruby 1.8.
    #
    if RUBY_VERSION =~ /^1\.9/
      @driver.image(:id => 'dfa924b7-83e8-4a5c-9d5c-1270fd0c0872').wont_be_nil
      @driver.image(:id => 'dfa924b7-83e8-4a5c-9d5c-1270fd0c0872').must_be_kind_of Image
      @driver.image(:id => 'dfa924b7-83e8-4a5c-9d5c-1270fd0c0872').id.must_equal 'dfa924b7-83e8-4a5c-9d5c-1270fd0c0872'
      @driver.image(:id => 'ami-aaaaaaaa').must_be_nil
      @driver.image(:id => 'unknown').must_be_nil
    end
  end

  it 'must throw proper exception when destroying used image' do
    if RUBY_VERSION =~ /^1\.9/
      image = @driver.image(:id => 'dfa924b7-83e8-4a5c-9d5c-1270fd0c0872')
      image.wont_be_nil
      image.state.must_equal 'OK'
      Proc.new {
        @driver.destroy_image(image.id)
      }.must_raise Deltacloud::ExceptionHandler::BackendError, 'Cannot delete Template. Template is being used by the following VMs: test1.'
    end
  end

  it 'must support destroying images' do
    image = @driver.image(:id => 'a90de8a2-0619-4625-b72e-db0ff65ef927')
    image.wont_be_nil
    image.state.must_equal 'OK'
    @driver.destroy_image(image.id)
    image.wait_for!(@driver) { |img| img.nil? }
  end

end
