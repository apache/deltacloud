$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/common'

module OpenstackTest

  class ImagesTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_01_it_returns_images
      get_auth_url '/api;driver=openstack/images'
      (last_xml_response/'images/image').length.should > 0
    end

    def test_02_each_image_has_correct_properties
      get_auth_url '/api;driver=openstack/images'
      (last_xml_response/'images/image').each do |image|
        (image/'name').should_not == nil
        (image/'name').should_not == ''
        (image/'description').should_not == nil
        (image/'description').should_not == ''
        (image/'architecture').should_not == nil
        (image/'architecture').should_not == ''
        (image/'state').text.should == 'ACTIVE'
        (image/'owner_id').text.should == ENV['API_USER']
        (image/'actions/link').length.should == 1
        (image/'actions/link').first[:rel].should == 'create_instance'
      end
    end

    def test_03_it_returns_single_image
      get_auth_url '/api;driver=openstack/images/1'
      (last_xml_response/'image').length.should == 1
    end

  end
end
