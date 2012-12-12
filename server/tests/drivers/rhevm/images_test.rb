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
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of images' do
    @driver.images.wont_be_empty
    @driver.images.first.must_be_kind_of Image
  end

  it 'must allow to filter images' do
    @driver.images(:id => '5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5').wont_be_empty
    @driver.images(:id => '5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5').must_be_kind_of Array
    @driver.images(:id => '5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5').size.must_equal 1
    @driver.images(:id => '5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5').first.id.must_equal '5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5'
    @driver.images(:owner_id => 'admin@internal').each do |img|
      img.owner_id.must_equal 'admin@internal'
    end
    @driver.images(:id => 'ami-aaaaaaaa').must_be_empty
    @driver.images(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single image' do
    # NOTE: This test will cause VCR to fail due to wrong serialization
    # of YAML under Ruby 1.8.
    #
    if RUBY_VERSION =~ /^1\.9/
      @driver.image(:id => '5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5').wont_be_nil
      @driver.image(:id => '5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5').must_be_kind_of Image
      @driver.image(:id => '5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5').id.must_equal '5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5'
      @driver.image(:id => 'ami-aaaaaaaa').must_be_nil
      @driver.image(:id => 'unknown').must_be_nil
    end
  end

  it 'must throw proper exception when destroying used image' do
    if RUBY_VERSION =~ /^1\.9/
      image = @driver.image(:id => '5558c5b6-9dd6-41b7-87f9-7cbce4fd40c5')
      image.wont_be_nil
      image.state.must_equal 'OK'
      Proc.new {
        @driver.destroy_image(image.id)
      }.must_raise Deltacloud::Exceptions::Conflict, 'Cannot delete Template. Template is being used by the following VMs: test1.'
    end
  end

  it 'must support destroying images' do
    image = @driver.image(:id => '5472e759-dee1-4e90-a2bf-79b61a601e80')
    image.wont_be_nil
    image.state.must_equal 'OK'
    @driver.destroy_image(image.id)
    image.wait_for!(@driver) { |img| img.nil? }
  end

end
