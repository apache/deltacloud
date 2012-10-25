require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'MockDriver Images' do

  before do
    @driver = Deltacloud::new(:mock, :user => 'mockuser', :password => 'mockpassword')
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.images(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of images' do
    @driver.images.wont_be_empty
    @driver.images.first.must_be_kind_of Image
  end

  it 'must allow to filter images' do
    @driver.images(:id => 'img1').wont_be_empty
    @driver.images(:id => 'img1').must_be_kind_of Array
    @driver.images(:id => 'img1').size.must_equal 1
    @driver.images(:id => 'img1').first.id.must_equal 'img1'
    @driver.images(:owner_id => 'mockuser').size.must_equal 1
    @driver.images(:owner_id => 'mockuser').first.owner_id.must_equal 'mockuser'
    @driver.images(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single image' do
    @driver.image(:id => 'img1').wont_be_nil
    @driver.image(:id => 'img1').must_be_kind_of Image
    @driver.image(:id => 'img1').id.must_equal 'img1'
    @driver.image(:id => 'unknown').must_be_nil
  end

  it 'must allow to create a new image if instance supported' do
    @driver.create_image(:id => 'inst1', :name => 'img1-test', :description => 'Test1').must_be_kind_of Image
    @driver.image(:id => 'img1-test').wont_be_nil
    @driver.image(:id => 'img1-test').id.must_equal 'img1-test'
    @driver.image(:id => 'img1-test').name.must_equal 'img1-test'
    @driver.image(:id => 'img1-test').description.must_equal 'Test1'
    Proc.new { @driver.create_image(:id => 'unknown-instance', :name => 'test') }.must_raise Deltacloud::Exceptions::BackendError, 'CreateImageNotSupported'
    @driver.image(:id => 'test').must_be_nil
  end

  it 'must allow to destroy created image' do
    @driver.create_image(:id => 'inst1', :name => 'img1-test-destroy').must_be_kind_of Image
    @driver.destroy_image('img1-test-destroy')
    @driver.image(:id => 'img1-test-destroy').must_be_nil
  end

  it 'must report image creation time' do
    @driver.image(:id => 'img1').wont_be_nil
    @driver.image(:id => 'img1').creation_time.wont_be_nil
  end

end
