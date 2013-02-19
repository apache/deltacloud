require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'FgcpDriver StorageVolumes' do

  before do
    @driver = Deltacloud::new(:fgcp, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.storage_volumes(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of storage_volumes' do
    @driver.storage_volumes.wont_be_empty
    @driver.storage_volumes.first.must_be_kind_of StorageVolume
  end

  it 'must allow to filter storage_volumes' do
    storage_volumes = @driver.storage_volumes(:id => 'UZXC0GRT-ZG8ZJCJ07-D-0039')
    storage_volumes.wont_be_empty
    storage_volumes.must_be_kind_of Array
    storage_volumes.size.must_equal 1
    storage_volumes.first.id.must_equal 'UZXC0GRT-ZG8ZJCJ07-D-0039'
    @driver.storage_volumes(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single storage_volume' do
    storage_volume = @driver.storage_volume(:id => 'UZXC0GRT-ZG8ZJCJ07-D-0039')
    storage_volume.wont_be_nil
    storage_volume.must_be_kind_of StorageVolume
    storage_volume.id.must_equal 'UZXC0GRT-ZG8ZJCJ07-D-0039'
    @driver.storage_volume(:id => 'unknown').must_be_nil
  end

  it 'must allow to create the storage volume' do
    volume = @driver.create_storage_volume(:name => 'Test Volume', :capacity => '2')
    volume.must_be_kind_of StorageVolume
    volume.name.must_equal 'Test Volume'
    volume.capacity.must_equal '10.0' # note that it's rounded up to a multiple of ten
    volume2 = @driver.storage_volume(:id => volume.id)
    volume2.wont_be_nil
    volume2.must_be_kind_of StorageVolume
    volume2.id.must_equal volume.id
    volume2.name.must_equal volume.name
    volume2.capacity.must_equal volume.capacity
  end

end
