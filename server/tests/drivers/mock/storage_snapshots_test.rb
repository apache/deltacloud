require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe 'MockDriver StorageSnapshots' do

  before do
    @driver = Deltacloud::new(:mock, :user => 'mockuser', :password => 'mockpassword')
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.storage_snapshots(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of storage_snapshots' do
    @driver.storage_snapshots.wont_be_empty
    @driver.storage_snapshots.first.must_be_kind_of StorageSnapshot
  end

  it 'must allow to filter storage_snapshots' do
    @driver.storage_snapshots(:id => 'snap1').wont_be_empty
    @driver.storage_snapshots(:id => 'snap1').must_be_kind_of Array
    @driver.storage_snapshots(:id => 'snap1').size.must_equal 1
    @driver.storage_snapshots(:id => 'snap1').first.id.must_equal 'snap1'
    @driver.storage_snapshots(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single storage_snapshot' do
    @driver.storage_snapshot(:id => 'snap1').wont_be_nil
    @driver.storage_snapshot(:id => 'snap1').must_be_kind_of StorageSnapshot
    @driver.storage_snapshot(:id => 'snap1').id.must_equal 'snap1'
    @driver.storage_snapshot(:id => 'unknown').must_be_nil
  end

end
