require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'GoGridDriver Images' do

  before do
    Time.be(DateTime.parse("2012-08-23 11:45:00 +0000").to_s)
    @driver = Deltacloud::new(:gogrid, credentials)
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
    @driver.images(:id => '9928').wont_be_empty
    @driver.images(:id => '9928').must_be_kind_of Array
    @driver.images(:id => '9928').size.must_equal 1
    @driver.images(:id => '9928').first.id.must_equal '9928'
    @driver.images(:id => '9928').first.name.must_equal 'CentOS 5.6 (32-bit) w/ None'
    @driver.images(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single image' do
    @driver.image(:id => '9928').wont_be_nil
    @driver.image(:id => '9928').must_be_kind_of Image
    @driver.image(:id => '9928').id.must_equal '9928'
    @driver.image(:id => 'unknown').must_be_nil
  end

end
