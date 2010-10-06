require 'tests/common'

module DeltacloudUnitTest
  class InstancesTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_it_require_authentication
      require_authentication?('/api/instances').should == true
    end

    def test_it_returns_instances
      do_xml_request '/api/instances', {}, true
      (last_xml_response/'instances/instance').to_a.size.should > 0
    end

    def test_it_has_correct_attributes_set
      do_xml_request '/api/images', {}, true
      (last_xml_response/'images/image').each do |image|
        image.attributes.keys.sort.should == [ 'href', 'id' ]
      end
    end

    def test_it_has_unique_ids
      do_xml_request '/api/instances', {}, true
      ids = []
      (last_xml_response/'instances/instance').each do |image|
        ids << image['id'].to_s
      end
      ids.sort.should == ids.sort.uniq
    end

    def test_inst1_has_correct_attributes
      do_xml_request '/api/instances', {}, true
      instance = (last_xml_response/'instances/instance[@id="inst1"]')
      test_instance_attributes(instance)
    end

    def test_it_returns_valid_realm
      do_xml_request '/api/instances/inst1', {}, true
      instance = (last_xml_response/'instance')
      test_instance_attributes(instance)
    end

    def test_it_responses_to_json
      do_request '/api/instances', {}, true, { :format => :json }
      JSON::parse(last_response.body).class.should == Hash
      JSON::parse(last_response.body)['instances'].class.should == Array

      do_request '/api/instances/inst1', {}, true, { :format => :json }
      last_response.status.should == 200
      JSON::parse(last_response.body).class.should == Hash
      JSON::parse(last_response.body)['instance'].class.should == Hash
    end

    def test_it_responses_to_html
      do_request '/api/instances', {}, true, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'

      do_request '/api/instances/inst1', {}, true, { :format => :html }
      last_response.status.should == 200
      Nokogiri::HTML(last_response.body).search('html').first.name.should == 'html'
    end

    def test_it_create_a_new_instance_using_image_id
      params = {
        :image_id => 'img1'
      }
      header 'Accept', accept_header(:xml)
      post '/api/instances', params, authenticate
      last_response.status.should == 201
      last_response.headers['Location'].should_not == nil
      do_xml_request last_response.headers['Location'], {}, true
      (last_xml_response/'instance/name').should_not == nil
      add_created_instance (last_xml_response/'instance').first['id']
      test_instance_attributes(last_xml_response/'instance')
    end

    def test_it_create_a_new_instance_using_image_id_and_name
      params = {
        :image_id => 'img1',
        :name => "unit_test_instance1"
      }
      header 'Accept', accept_header(:xml)
      post '/api/instances', params, authenticate(:format => :xml)
      last_response.status.should == 201
      last_response.headers['Location'].should_not == nil
      do_xml_request last_response.headers['Location'], {}, true
      (last_xml_response/'instance/name').text.should == 'unit_test_instance1'
      add_created_instance (last_xml_response/'instance').first['id']
      test_instance_attributes(last_xml_response/'instance')
    end

    def test_it_create_a_new_instance_using_image_id_and_name_and_hwp
      params = {
        :image_id => 'img1',
        :name => "unit_test_instance1",
        :hwp_id => "m1-xlarge"
      }
      header 'Accept', accept_header(:xml)
      post '/api/instances', params, authenticate(:format => :xml)
      last_response.status.should == 201
      last_response.headers['Location'].should_not == nil
      do_xml_request last_response.headers['Location'], {}, true
      (last_xml_response/'instance/name').text.should == 'unit_test_instance1'
      (last_xml_response/'instance/hardware_profile').first['id'].should == 'm1-xlarge'
      add_created_instance (last_xml_response/'instance').first['id']
      test_instance_attributes(last_xml_response/'instance')
    end

    def test_it_z0_stop_and_start_instance
      $created_instances.each do |instance_id|
        do_xml_request "/api/instances/#{instance_id}", {}, true
        stop_url = (last_xml_response/'actions/link[@rel="stop"]').first['href']
        stop_url.should_not == nil
        post create_url(stop_url), { :format => 'xml' }, authenticate
        last_response.status.should == 200
        instance = Nokogiri::XML(last_response.body)
        test_instance_attributes(instance)
        (instance/'state').text.should == 'STOPPED'
        do_xml_request "/api/instances/#{instance_id}", {}, true
        start_url = (last_xml_response/'actions/link[@rel="start"]').first['href']
        start_url.should_not == nil
        post create_url(start_url), { :format => 'xml'}, authenticate
        last_response.status.should == 200
        instance = Nokogiri::XML(last_response.body)
        test_instance_attributes(instance)
        (instance/'state').text.should == 'RUNNING'
      end
    end

    def test_z0_reboot_instance
      $created_instances.each do |instance_id|
        do_xml_request "/api/instances/#{instance_id}", {}, true
        reboot_url = (last_xml_response/'actions/link[@rel="reboot"]').first['href']
        reboot_url.should_not == nil
        post create_url(reboot_url), { :format => "xml"}, authenticate
        last_response.status.should == 200
        instance = Nokogiri::XML(last_response.body)
        test_instance_attributes(instance)
        (instance/'state').text.should == 'RUNNING'
      end
    end

    def test_z1_stop_created_instances
      $created_instances.each do |instance_id|
        do_xml_request "/api/instances/#{instance_id}", {}, true
        stop_url = (last_xml_response/'actions/link[@rel="stop"]').first['href']
        stop_url.should_not == nil
        post create_url(stop_url), {}, authenticate
        last_response.status.should == 200
        instance = Nokogiri::XML(last_response.body)
        test_instance_attributes(instance)
        (instance/'state').text.should == 'STOPPED'
      end
    end

    def test_z2_destroy_created_instances
      $created_instances.each do |instance_id|
        do_xml_request "/api/instances/#{instance_id}", {}, true
        destroy_url = (last_xml_response/'actions/link[@rel="destroy"]').first['href']
        destroy_url.should_not == nil
        delete create_url(destroy_url), {}, authenticate
        last_response.status.should == 302
        do_xml_request last_response.headers['Location'], {}, true
        (last_xml_response/'instances').should_not == nil
        do_xml_request "/api/instances/#{instance_id}", {}, true
        last_response.status.should == 404
      end
    end

    private

    def test_instance_attributes(instance)
      (instance/'name').should_not == nil
      (instance/'owner_id').should_not == nil
      ['RUNNING', 'STOPPED'].include?((instance/'state').text).should == true

      (instance/'public_addreses').should_not == nil
      (instance/'public_addresses/address').to_a.size.should > 0
      (instance/'public_addresses/address').first.text.should_not == ""

      (instance/'private_addresses').should_not == nil
      (instance/'private_addresses/address').to_a.size.should > 0
      (instance/'private_addresses/address').first.text.should_not == ""

      (instance/'actions/link').to_a.size.should > 0
      (instance/'actions/link').each do |link|
        link['href'].should_not == ""
        link['rel'].should_not == ""
        link['method'].should_not == ""
        ['get', 'post', 'delete', 'put'].include?(link['method']).should == true
      end

      (instance/'image').size.should > 0
      (instance/'image').first['href'].should_not == ""
      (instance/'image').first['id'].should_not == ""
      do_xml_request (instance/'image').first['href'], {}, true
      (last_xml_response/'image').should_not == nil
      (last_xml_response/'image').first['href'] == (instance/'image').first['href']

      (instance/'realm').size.should > 0
      (instance/'realm').first['href'].should_not == ""
      (instance/'realm').first['id'].should_not == ""
      do_xml_request (instance/'realm').first['href']
      (last_xml_response/'realm').should_not == nil
      (last_xml_response/'realm').first['href'] == (instance/'realm').first['href']

      (instance/'hardware_profile').size.should > 0
      (instance/'hardware_profile').first['href'].should_not == ""
      (instance/'hardware_profile').first['id'].should_not == ""
      do_xml_request (instance/'hardware_profile').first['href']
      (last_xml_response/'hardware_profile').should_not == nil
      (last_xml_response/'hardware_profile').first['href'] == (instance/'hardware_profile').first['href']
    end

  end
end
