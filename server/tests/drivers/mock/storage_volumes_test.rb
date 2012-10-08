require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'MockDriver StorageVolumes' do

  before do
    @driver = Deltacloud::new(:mock, :user => 'mockuser', :password => 'mockpassword')
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
    @driver.storage_volumes(:id => 'vol1').wont_be_empty
    @driver.storage_volumes(:id => 'vol1').must_be_kind_of Array
    @driver.storage_volumes(:id => 'vol1').size.must_equal 1
    @driver.storage_volumes(:id => 'vol1').first.id.must_equal 'vol1'
    @driver.storage_volumes(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single storage_volume' do
    @driver.storage_volume(:id => 'vol1').wont_be_nil
    @driver.storage_volume(:id => 'vol1').must_be_kind_of StorageVolume
    @driver.storage_volume(:id => 'vol1').id.must_equal 'vol1'
    @driver.storage_volume(:id => 'unknown').must_be_nil
  end

  it 'must allow to create and destroy the storage volume' do
    volume = @driver.create_storage_volume(:name => 'Test Volume', :capacity => '100')
    volume.must_be_kind_of StorageVolume
    volume.name.must_equal 'Test Volume'
    volume.capacity.must_equal '100'
    @driver.destroy_storage_volume(:id => volume.id)
    @driver.storage_volume(:id => volume.id).must_be_nil
  end

  it 'must allow to attach and detach storage volume to instance' do
    volume = @driver.create_storage_volume(:name => 'Test Volume', :capacity => '100')
    volume.must_be_kind_of StorageVolume
    @driver.attach_storage_volume(:id => volume.id, :device => '/dev/sda', :instance_id => 'inst1')
    @driver.storage_volume(:id => volume.id).instance_id.must_equal 'inst1'
    @driver.storage_volume(:id => volume.id).device.must_equal '/dev/sda'
    @driver.detach_storage_volume(:id => volume.id, :instance_id => 'inst1')
    @driver.storage_volume(:id => volume.id).instance_id.must_be_nil
    @driver.storage_volume(:id => volume.id).device.must_be_nil
    @driver.destroy_storage_volume(:id => volume.id)
    @driver.storage_volume(:id => volume.id).must_be_nil
  end

end
