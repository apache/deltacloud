require 'tests/deltacloud_test'

class StorageVolumesTest < Test::Unit::TestCase

  def initialize(*args)
    @collection = 'storage_volumes'
    @operations = [:index, :show]
    @options = [:id, :architecture, :memory, :storage]
    @params = {}
    super(*args)
  end

  def test_if_storage_volumes_are_not_empty
    get '/api/storage_volumes.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_not_equal 0, doc.xpath('/storage-volumes/storage-volume').size
  end

  [:id, :created, :capacity, :device, :state].each do |option|
    method_name = :"test_if_storage_volumes_index_contain_#{option}"
    send :define_method, method_name do
      get '/api/storage_volumes.xml', @params, rack_headers
      doc = Nokogiri::XML.parse(last_response.body)
      storage_volume = doc.xpath('/storage-volumes/storage-volume[1]').first
      assert_not_nil storage_volume.xpath(option.to_s).first
    end
  end

  [:id, :created, :capacity, :device, :state].each do |option|
    method_name = :"test_if_storage_volume_show_contain_#{option}"
    send :define_method, method_name do
      get '/api/storage_volumes/vol2.xml', @params, rack_headers
      doc = Nokogiri::XML.parse(last_response.body)
      storage_volume = doc.xpath('/storage-volume').first
      assert_not_nil storage_volume.xpath(option.to_s).first
    end
  end

  def test_storage_volumes_filtering_by_id
    get '/api/storage_volumes.xml', { :id => 'vol2'}, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 1, doc.xpath('/storage-volumes/storage-volume').size
    assert_equal 'vol2', doc.xpath('/storage-volumes/storage-volume/id').first.text
  end

  include DeltacloudTest

end
