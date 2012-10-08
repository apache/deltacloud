require 'minitest/autorun'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'api.rb')
require_relative 'common.rb'

describe 'OpenStackDriver Images' do

  before do
    @driver = Deltacloud::new(:openstack, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.images(OpenStruct.new(:user => 'unknown+wrong', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of images' do
    @driver.images.wont_be_empty
    @driver.images.first.must_be_kind_of Image
  end

  it 'must allow to filter images' do
    images = @driver.images :id => openstack_image_id
    images.wont_be_empty
    images.must_be_kind_of Array
    images.size.must_equal 1
    images.first.id.must_equal openstack_image_id
    @driver.images(:owner_id => 'admin').wont_be_empty
    @driver.images(:owner_id => 'unknown').must_be_empty
    @driver.images(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single image' do
    @driver.image(:id => 'unknown').must_be_nil
    image = @driver.image :id => openstack_image_id
    image.wont_be_nil
    image.must_be_kind_of Image
    image.id.must_equal openstack_image_id
    image.name.wont_be_empty
    image.owner_id.wont_be_empty
    image.state.wont_be_empty
  end

end
