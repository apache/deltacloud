require 'tests/deltacloud_test'

class FlavorsTest < Test::Unit::TestCase

  def initialize(*args)
    @collection = 'flavors'
    @operations = [:index, :show]
    @options = [:id, :architecture, :memory, :storage]
    @params = {}
    super(*args)
  end

  def test_if_flavors_are_not_empty
    get '/api/flavors.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_not_equal 0, doc.xpath('/flavors/flavor').size
  end

  [:id, :architecture, :memory, :storage].each do |option|
    method_name = :"test_if_flavors_index_contain_#{option}"
    send :define_method, method_name do
      get '/api/flavors.xml', @params, rack_headers
      doc = Nokogiri::XML.parse(last_response.body)
      flavor = doc.xpath('/flavors/flavor[1]').first
      assert_not_nil flavor.xpath(option.to_s).first
    end
  end

  [:id, :architecture, :memory, :storage].each do |option|
    method_name = :"test_if_flavor_show_contain_#{option}"
    send :define_method, method_name do
      get '/api/flavors/m1-small.xml', @params, rack_headers
      doc = Nokogiri::XML.parse(last_response.body)
      flavor = doc.xpath('/flavor').first
      assert_not_nil flavor.xpath(option.to_s).first
    end
  end

  def test_flavors_filtering_by_architecture
    @params[:architecture] = 'i386'
    get '/api/flavors.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 1, doc.xpath('/flavors/flavor').size
    assert_equal @params[:architecture], doc.xpath('/flavors/flavor/architecture').first.text
  end

  def test_flavors_filtering_by_id
    get '/api/flavors.xml', { :id => 'm1-small'}, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 1, doc.xpath('/flavors/flavor').size
    assert_equal 'm1-small', doc.xpath('/flavors/flavor/id').first.text
  end

  def test_flavors_filtering_by_id_and_architecture
    get '/api/flavors.xml', { :architecture => 'x86_64', :id => 'c1-xlarge'}, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 1, doc.xpath('/flavors/flavor').size
    assert_equal 'c1-xlarge', doc.xpath('/flavors/flavor/id').first.text
    assert_equal 'x86_64', doc.xpath('/flavors/flavor/architecture').first.text
  end

  include DeltacloudTest

end

