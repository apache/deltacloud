require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative File.join('..', 'common.rb')

describe Deltacloud::Collections::StorageVolumes do

  before do
    def app; run_frontend; end
    authorize 'mockuser', 'mockpassword'
    @collection = Deltacloud::Collections.collection(:storage_volumes)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal Deltacloud::Rabbit::StorageVolumesCollection::IndexOperation
  end

  it 'has show operation' do
    @collection.operation(:show).must_equal Deltacloud::Rabbit::StorageVolumesCollection::ShowOperation
  end

  it 'returns list of storage_volumes in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/storage_volumes'
      status.must_equal 200
    end
  end

  it 'returns details about storage_volume in various formats with show operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/storage_volumes/vol1'
      status.must_equal 200
    end
  end

  it 'reports 404 when querying non-existing key' do
    get root_url + '/storage_volumes/unknown'
    status.must_equal 404
  end

  it 'properly serialize attributes in JSON' do
    check_json_serialization_for :storage_volume, 'vol1'
  end

end
