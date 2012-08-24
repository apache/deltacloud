require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'GoGridDriver Instances' do

  before do
    Time.be(DateTime.parse("2012-08-23 12:12:00 +0000").to_s)
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

  it 'must return list of instances' do
    @driver.instances.wont_be_empty
    @driver.instances.first.must_be_kind_of Instance
  end

  it 'must allow to filter instances' do
    @driver.instances(:id => 'test').wont_be_empty
    @driver.instances(:id => 'test').must_be_kind_of Array
    @driver.instances(:id => 'test').size.must_equal 1
    @driver.instances(:id => 'test').first.id.must_equal 'test'
    @driver.instances(:owner_id => '9bbf139b8b57d967').wont_be_empty
    @driver.instances(:owner_id => '9bbf139b8b57d967').each do |inst|
      inst.owner_id.must_equal '9bbf139b8b57d967'
    end
    @driver.instances(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single instance' do
    @driver.instance(:id => 'test').wont_be_nil
    @driver.instance(:id => 'test').must_be_kind_of Instance
    @driver.instance(:id => 'test').id.must_equal 'test'
    @driver.instance(:id => 'unknown').must_be_nil
  end

end
