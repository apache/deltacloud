require 'tests/common'

module DeltacloudUnitTest
  class HardwareProfilesTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_it_require_authentication
      require_authentication?('/api/images').should == true
    end

    def test_it_returns_images
      do_xml_request '/api/images', {}, true
      (last_xml_response/'images/image').to_a.size.should > 0
    end

    def test_it_has_correct_attributes_set
      do_xml_request '/api/images', {}, true
      (last_xml_response/'images/image').each do |image|
        image.attributes.keys.sort.should == [ 'href', 'id' ]
      end
    end

    def test_img1_has_correct_attributes
      do_xml_request '/api/images', {}, true
      image = (last_xml_response/'images/image[@id="img1"]')
      test_image_attributes(image)
    end

    def test_it_returns_valid_image
      do_xml_request '/api/images/img1', {}, true
      image = (last_xml_response/'image')
      test_image_attributes(image)
    end

    def test_it_has_unique_ids
      do_xml_request '/api/images', {}, true
      ids = []
      (last_xml_response/'images/image').each do |image|
        ids << image['id'].to_s
      end
      ids.sort.should == ids.sort.uniq
    end

    def test_it_has_valid_urls
      do_xml_request '/api/images', {}, true
      ids = []
      images = (last_xml_response/'images/image')
      images.each do |image|
        do_xml_request image['href'].to_s, {}, true
        (last_xml_response/'image').first['href'].should == image['href'].to_s
      end
    end

    def test_it_can_filter_using_owner_id
      do_xml_request '/api/images', { :owner_id => 'mockuser' }, true
      (last_xml_response/'images/image').size.should == 1
      (last_xml_response/'images/image/owner_id').first.text.should == 'mockuser'
    end

    def test_it_can_filter_using_unknown_owner_id
      do_xml_request '/api/images', { :architecture => 'unknown_user' }, true
      (last_xml_response/'images/image').size.should == 0
    end

    def test_it_can_filter_using_architecture
      do_xml_request '/api/images', { :architecture => 'x86_64' }, true
      (last_xml_response/'images/image').size.should == 1
      (last_xml_response/'images/image/architecture').first.text.should == 'x86_64'
    end

    def test_it_can_filter_using_unknown_architecture
      do_xml_request '/api/images', { :architecture => 'unknown_arch' }, true
      (last_xml_response/'images/image').size.should == 0
    end

    def test_it_responses_to_json
      do_request '/api/images', {}, true, { :format => :json }
      JSON::parse(last_response.body).class.should == Hash
      JSON::parse(last_response.body)['images'].class.should == Array

      do_request '/api/images/img1', {}, true, { :format => :json }
      last_response.status.should == 200
      JSON::parse(last_response.body).class.should == Hash
      JSON::parse(last_response.body)['image'].class.should == Hash
    end

    def test_it_responses_to_html
      do_request '/api/images', {}, true, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'

      do_request '/api/images/img1', {}, true, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'
    end

    private

    def test_image_attributes(image)
      (image/'name').text.should_not nil
      (image/'owner_id').text.should_not nil
      (image/'description').text.should_not nil
      (image/'architecture').text.should_not nil
    end

  end
end
