require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'RhevmDriver Images' do

  before do
    prefs = Deltacloud::Test::config.preferences(:rhevm)
    @template_id = prefs["template"]

    @driver = Deltacloud::Test::config.driver(:rhevm)
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
    @driver.images.first.must_be_kind_of Image
  end

  it 'must allow to filter images' do
    imgs = @driver.images(:id => @template_id)
    imgs.wont_be_empty
    imgs.must_be_kind_of Array
    imgs.size.must_equal 1
    imgs.first.id.must_equal @template_id
    owner_id = imgs.first.owner_id
    @driver.images(:owner_id => owner_id).each do |img|
      img.owner_id.must_equal owner_id
    end
    @driver.images(:id => 'ami-aaaaaaaa').must_be_empty
    @driver.images(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single image' do
    # NOTE: This test will cause VCR to fail due to wrong serialization
    # of YAML under Ruby 1.8.
    #
    if RUBY_VERSION =~ /^1\.9/
      img = @driver.image(:id => @template_id)
      img.wont_be_nil
      img.must_be_kind_of Image
      img.id.must_equal @template_id
      @driver.image(:id => 'ami-aaaaaaaa').must_be_nil
      @driver.image(:id => 'unknown').must_be_nil
    end
  end

  it 'must throw proper exception when destroying used image' do
    if RUBY_VERSION =~ /^1\.9/
      image = @driver.image(:id => @template_id)
      image.wont_be_nil
      image.state.must_equal 'OK'
      Proc.new {
        @driver.destroy_image(image.id)
      }.must_raise Deltacloud::Exceptions::Conflict, 'Cannot delete Template. Template is being used by the following VMs: test1.'
    end
  end

  it 'must support destroying images' do
    skip "Depends on hardcoded image"
    # FIXME: we need to create a new image here, and then destroy it
    image = @driver.image(:id => '5472e759-dee1-4e90-a2bf-79b61a601e80')
    image.wont_be_nil
    image.state.must_equal 'OK'
    @driver.destroy_image(image.id)
    image.wait_for!(@driver) { |img| img.nil? }
  end

end
