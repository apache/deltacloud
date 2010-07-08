require 'tests/deltacloud_test'

class RealmsTest < Test::Unit::TestCase

  def initialize(*args)
    @collection = 'realms'
    @operations = [:index, :show]
    @options = [:id, :name, :state]
    @params = {}
    super(*args)
  end

  def test_if_realms_are_not_empty
    get '/api/realms.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_not_equal 0, doc.xpath('/realms/realm').size
  end

  [:id, :name, :state].each do |option|
    method_name = :"test_if_realms_index_contain_#{option}"
    send :define_method, method_name do
      get '/api/realms.xml', @params, rack_headers
      doc = Nokogiri::XML.parse(last_response.body)
      realm = doc.xpath('/realms/realm[1]').first
      assert_not_nil realm.xpath(option.to_s).first
    end
  end

  [:id, :name, :state].each do |option|
    method_name = :"test_if_realm_show_contain_#{option}"
    send :define_method, method_name do
      get '/api/realms/us.xml', @params, rack_headers
      doc = Nokogiri::XML.parse(last_response.body)
      realm = doc.xpath('/realm').first
      assert_not_nil realm.xpath(option.to_s).first
    end
  end

  def test_realms_filtering_by_state
    @params[:state] = 'AVAILABLE'
    get '/api/realms.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 2, doc.xpath('/realms/realm').size
    assert_equal @params[:state], doc.xpath('/realms/realm/state').first.text
  end

  def test_realms_filtering_by_id
    get '/api/realms.xml', { :id => 'us'}, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 1, doc.xpath('/realms/realm').size
    assert_equal 'us', doc.xpath('/realms/realm/id').first.text
  end

  include DeltacloudTest

end
