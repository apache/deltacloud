require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'GoGridDriver Images' do

  def credentials
  {
    :user => "04825b9fb0826b0b",
    :password => "gogrid_deltacloud_te"
  }
  end

  before do
    @driver = Deltacloud::new(:gogrid, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.images(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of images' do
    @driver.images.wont_be_empty
    @driver.images.first.must_be_kind_of Deltacloud::Image
  end

  it 'must allow to filter images' do
    img = @driver.images.first
    img.wont_be_nil

    imgs = @driver.images(:id => img.id)
    imgs.wont_be_empty
    imgs.must_be_kind_of Array
    imgs.size.must_equal 1
    imgs.first.id.must_equal img.id
    imgs.first.name.must_equal img.name
  end

  it 'must return an empty array for nonexistent image' do
    @driver.images(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single image' do
    some_img = @driver.images.first
    some_img.wont_be_nil
    by_id = @driver.image(:id => some_img.id)

    by_id.wont_be_nil
    by_id.must_be_kind_of Deltacloud::Image
    by_id.id.must_equal some_img.id
  end

  it 'must return nil when retrieving a single nonexistent image' do
    @driver.image(:id => 'unknown').must_be_nil
  end
end
