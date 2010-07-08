require 'tests/deltacloud_test'

class StorageSnapshotsTest < Test::Unit::TestCase 

  def initialize(*args)
    @collection = 'storage_snapshots'
    @operations = [:index, :show]
    @options = [:id, :architecture, :memory, :storage]
    @params = {}
    super(*args)
  end

  def test_if_storage_snapshots_are_not_empty
    get '/api/storage_snapshots.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_not_equal 0, doc.xpath('/storage-snapshots/storage-snapshot').size
  end

  [:id, :created, :state, :'storage-volume'].each do |option|
    method_name = :"test_if_storage_snapshots_index_contain_#{option}"
    send :define_method, method_name do
      get '/api/storage_snapshots.xml', @params, rack_headers
      doc = Nokogiri::XML.parse(last_response.body)
      storage_volume = doc.xpath('/storage-snapshots/storage-snapshot[1]').first
      assert_not_nil storage_volume.xpath(option.to_s).first
    end
  end

  [:id, :created, :state, :'storage-volume'].each do |option|
    method_name = :"test_if_storage_volume_show_contain_#{option}"
    send :define_method, method_name do
      get '/api/storage_snapshots/snap3.xml', @params, rack_headers
      doc = Nokogiri::XML.parse(last_response.body)
      storage_volume = doc.xpath('/storage-snapshot').first
      assert_not_nil storage_volume.xpath(option.to_s).first
    end
  end

  def test_storage_snapshots_filtering_by_id
    get '/api/storage_snapshots.xml', { :id => 'snap3'}, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 1, doc.xpath('/storage-snapshots/storage-snapshot').size
    assert_equal 'snap3', doc.xpath('/storage-snapshots/storage-snapshot/id').first.text
  end

  include DeltacloudTest
  
end

