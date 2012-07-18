$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/openstack/common'

module OpenstackTest

  class ImagesTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Rack::Builder.new {
        map '/' do
          use Rack::Static, :urls => ["/stylesheets", "/javascripts"], :root => "public"
          run Rack::Cascade.new([Deltacloud::API])
        end
      }
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
        ENV['API_USER'].include?((image/'owner_id').text).should == true
        (image/'actions/link').length.should == 2
        (image/'actions/link').first[:rel].should == 'create_instance'
      end
      @@image_id = ((last_xml_response/'images/image').first)[:id]
    end

    def test_03_it_returns_single_image
      get_auth_url "/api;driver=openstack/images/#{@@image_id}"
      (last_xml_response/'image').length.should == 1
    end

  end
end
