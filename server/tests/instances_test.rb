require 'tests/deltacloud_test'

class InstancesTest < Test::Unit::TestCase

  def initialize(*args)
    @collection = 'instances'
    @operations = [:index, :show]
    @options = [:id, :architecture, :memory, :storage]
    @params = {}
    self.temp_inst_id = 'inst2'
    super(*args)
  end

  attr_accessor :temp_inst_id

  def test_if_instances_are_not_empty
    get '/api/instances.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_not_equal 0, doc.xpath('/instances/instance').size
  end

  [:id, :name, :owner_id, :image, :realm, :state, :actions, :'public-addresses', :'private-addresses'].each do |option|
    method_name = :"test_if_instances_index_contain_#{option}"
    send :define_method, method_name do
      get '/api/instances.xml', @params, rack_headers
      doc = Nokogiri::XML.parse(last_response.body)
      instance = doc.xpath('/instances/instance[1]').first
      assert_not_nil instance.xpath(option.to_s).first
    end
  end

  [:id, :name, :owner_id, :image, :realm, :state, :actions, :'public-addresses', :'private-addresses'].each do |option|
    method_name = :"test_if_instance_show_contain_#{option}"
    send :define_method, method_name do
      get '/api/instances/inst1.xml', @params, rack_headers
      doc = Nokogiri::XML.parse(last_response.body)
      instance = doc.xpath('/instance').first
      assert_not_nil instance.xpath(option.to_s).first
    end
  end

  def test_instances_filtering_by_id
    get '/api/instances.xml', { :id => 'inst1'}, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 1, doc.xpath('/instances/instance').size
    assert_equal 'inst1', doc.xpath('/instances/instance/id').first.text
  end

  def test_instances_filtering_by_state
    get '/api/instances.xml', { :state => 'RUNNING'}, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    doc.xpath('/instances/instance').each do |instance|
      assert_equal 'RUNNING', instance.xpath('state').first.text
    end
  end

  def test_instances_filtering_by_unknown_state
    get '/api/instances.xml', { :state => '_TEST_UNKNOWN_STATE'}, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 0, doc.xpath('/instances/instance').size
  end

  def test_001_create_instance
    @params = {
      :name     => '_test-instance',
      :image_id => 'img1'
    }

    post '/api/instances.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)

    self.temp_inst_id = doc.xpath('/instance/id').text

    assert_equal @params[:name], doc.xpath('/instance/name').first.text
    image_href = doc.xpath('/instance/image').first[:href].to_s
    image_id = image_href.gsub(/.*\/(\w+)$/, '\1')
    assert_equal @params[:image_id], image_id
  end

  def test_create_instance_with_hwp_id

    @params = {
      :name     => '_test-instance',
      :image_id => 'img1',
      :hwp_id => 'm1-xlarge'
    }

    post '/api/instances.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    hwp_href = doc.xpath('/instance/hardware_profile').first[:href].to_s
    hwp_id = hwp_href.gsub(/.*\/([\w\-]+)$/, '\1')
    assert_equal @params[:hwp_id], hwp_id
  end

  def test_create_instance_with_realm_id

    @params = {
      :name     => '_test-instance',
      :image_id => 'img1',
      :realm_id => 'us'
    }

    post '/api/instances.xml', @params, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    realm_href = doc.xpath('/instance/realm').first[:href].to_s
    realm_id = realm_href.gsub(/.*\/([\w\-]+)$/, '\1')
    assert_equal @params[:realm_id], realm_id
  end

  def test_002_stop_instance
    post '/api/instances/'+self.temp_inst_id+'/stop.xml', rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 'STOPPED', doc.xpath('/instance/state').first.text
  end

  def test_003_start_instance
    post '/api/instances/'+self.temp_inst_id+'/start.xml', rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 'RUNNING', doc.xpath('/instance/state').first.text
  end

  def test_004_reboot_instance
    post '/api/instances/'+self.temp_inst_id+'/reboot.xml', rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert_equal 'RUNNING', doc.xpath('/instance/state').first.text
  end

  def test_005_destroy_instance
    delete '/api/instances/'+self.temp_inst_id+'.xml', {}, rack_headers
    doc = Nokogiri::XML.parse(last_response.body)
    assert last_response.ok?
  end

  include DeltacloudTest

end
