require 'minitest/autorun'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'api.rb')
require_relative 'common.rb'

describe 'Ec2Driver Images' do

  before do
    @driver = Deltacloud::new(:ec2, credentials)
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
    @driver.images(:id => 'ami-aecd60c7').wont_be_empty
    @driver.images(:id => 'ami-aecd60c7').must_be_kind_of Array
    @driver.images(:id => 'ami-aecd60c7').size.must_equal 1
    @driver.images(:id => 'ami-aecd60c7').first.id.must_equal 'ami-aecd60c7'
    @driver.images(:owner_id => '137112412989').each do |img|
      img.owner_id.must_equal '137112412989'
    end
    @driver.images(:id => 'ami-aaaaaaaa').must_be_empty
    @driver.images(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single image' do
    @driver.image(:id => 'ami-aecd60c7').wont_be_nil
    @driver.image(:id => 'ami-aecd60c7').must_be_kind_of Image
    @driver.image(:id => 'ami-aecd60c7').id.must_equal 'ami-aecd60c7'
    @driver.image(:id => 'ami-aaaaaaaa').must_be_nil
    @driver.image(:id => 'unknown').must_be_nil
  end

end

