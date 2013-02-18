#$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'FGCP Images' do

  before do
    @driver = Deltacloud::new(:fgcp, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must return list of images' do
    imgs = @driver.images
    imgs.wont_be_empty
    imgs.first.must_be_kind_of Image
  end

  it 'must allow to filter images' do
    img = @driver.images(:id => 'IMG_3c9820_S24FWXU0Q9VH0JK')
    img.wont_be_empty
    img.must_be_kind_of Array
    img.size.must_equal 1
    img.first.id.must_equal 'IMG_3c9820_S24FWXU0Q9VH0JK'
    @driver.images(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single image' do
    img = @driver.image(:id => 'IMG_3c9820_S24FWXU0Q9VH0JK')
    img.wont_be_nil
    img.must_be_kind_of Image
    img.id.must_equal 'IMG_3c9820_S24FWXU0Q9VH0JK'
    @driver.image(:id => 'unknown').must_be_nil
  end

end
