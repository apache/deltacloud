require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'Ec2Driver StorageSnapshots' do
  before do
    Time.be(DateTime.parse("2012-08-13 13:03:00 +0000").to_s)
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

  it 'must return list of storage snapshots' do
    @driver.storage_snapshots.wont_be_empty
    @driver.storage_snapshots.first.must_be_kind_of StorageSnapshot
  end

  it 'must allow to filter storage snapshots' do
    @driver.storage_snapshots(:id => 'snap-e5bc8d95').wont_be_empty
    @driver.storage_snapshots(:id => 'snap-e5bc8d95').must_be_kind_of Array
    @driver.storage_snapshots(:id => 'snap-e5bc8d95').size.must_equal 1
    @driver.storage_snapshots(:id => 'snap-e5bc8d95').first.id.must_equal 'snap-e5bc8d95'
    @driver.storage_snapshots(:id => 'snap-00000000').must_be_empty
  end

  it 'must allow to create and destroy the storage snapshot' do
    record_options = record_retries.merge(:method => :storage_snapshot)

    # Create the new storage snapshot
    snapshot = @driver.create_storage_snapshot(:volume_id => 'vol-732cf013')
    snapshot.wait_for!(@driver, record_options) { |i| i.is_completed? }

    # Get created snapshot and check its properties
    snapshot = @driver.storage_snapshot(:id => snapshot.id)
    snapshot.is_completed?.must_equal true
    snapshot.storage_volume_id.must_equal 'vol-732cf013'

    # Destroy the snapshot at the end
    @driver.destroy_storage_snapshot(:id => snapshot.id)
    snapshot.wait_for!(@driver, record_options) { |i| i.nil? }
    @driver.storage_snapshot(:id => snapshot.id).must_be_nil
  end

end
