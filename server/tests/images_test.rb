require 'tests/deltacloud_test'

class ImagesTest < Test::Unit::TestCase

  def initialize(*args)
    @collection = 'images'
    @operations = [:index, :show]
    @params = {}
    super(*args)
  end

  def test_if_images_are_not_empty
    get '/api/images.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_not_equal 0, doc.xpath('/images/image').size
  end

  [:id, :owner_id, :name, :description, :architecture].each do |option|
    method_name = :"test_if_images_index_contain_#{option}"
    send :define_method, method_name do
      get '/api/images.xml', @params, rack_headers
      doc = Nokogiri::XML.parse(last_response.body)
      elt = doc.xpath('/images/image[1]').first
      assert_not_nil elt.xpath(option.to_s).first
    end
  end

  [:id, :owner_id, :name, :description, :architecture].each do |option|
    method_name = :"test_if_image_show_contain_#{option}"
    send :define_method, method_name do
      get '/api/images/img1.xml', @params, rack_headers
      doc = Nokogiri::XML.parse(last_response.body)
      elt = doc.xpath('/image').first
      assert_not_nil elt.xpath(option.to_s).first
    end
  end

  def test_images_filtering_by_id
    @params={ :id => 'img1' }
    get '/api/images.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 1, doc.xpath('/images/image').size
    assert_equal @params[:id], doc.xpath('/images/image/id').first.text
  end

  def test_images_filtering_by_owner_id
    @params={ :owner_id => 'fedoraproject' }
    get '/api/images.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 2, doc.xpath('/images/image').size
    assert_equal @params[:owner_id], doc.xpath('/images/image/owner_id')[0].text
    assert_equal @params[:owner_id], doc.xpath('/images/image/owner_id')[1].text
  end

  def test_images_filtering_by_architecture
    @params={ :architecture => 'i386' }
    get '/api/images.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 2, doc.xpath('/images/image').size
    assert_equal @params[:architecture], doc.xpath('/images/image/architecture')[0].text
    assert_equal @params[:architecture], doc.xpath('/images/image/architecture')[1].text
  end

  def test_images_filtering_by_id_and_owner_id
    @params={ :id => 'img1', :owner_id => 'fedoraproject' }
    get '/api/images.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 1, doc.xpath('/images/image').size
    assert_equal @params[:owner_id], doc.xpath('/images/image/owner_id')[0].text
    assert_equal @params[:id], doc.xpath('/images/image/id')[0].text
  end

  def test_images_filtering_by_id_and_owner_id_and_architecture
    @params={ :id => 'img1', :owner_id => 'fedoraproject', :architecture => 'x86_64' }
    get '/api/images.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 1, doc.xpath('/images/image').size
    assert_equal @params[:owner_id], doc.xpath('/images/image/owner_id')[0].text
    assert_equal @params[:id], doc.xpath('/images/image/id')[0].text
    assert_equal @params[:architecture], doc.xpath('/images/image/architecture')[0].text
  end

  def test_images_filtering_by_id_and_architecture
    @params={ :id => 'img1', :architecture => 'x86_64' }
    get '/api/images.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 1, doc.xpath('/images/image').size
    assert_equal @params[:id], doc.xpath('/images/image/id')[0].text
    assert_equal @params[:architecture], doc.xpath('/images/image/architecture')[0].text
  end

  include DeltacloudTest

end
