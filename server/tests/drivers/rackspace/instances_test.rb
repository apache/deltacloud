$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/common'

module RackspaceTest

  class InstancesTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_01_01_it_can_create_instance_without_hardware_profile
      params = {
        :image_id => '71',
        :'api[driver]' => 'rackspace',
      }
      header 'Accept', accept_header(:xml)
      post '/api/instances', params, authenticate
      last_response.status.should == 201 # Created
      @@instance = Nokogiri::XML(last_response.body)
      (@@instance/'instance').length.should > 0
      (@@instance/'instance/name').first.text.should_not == nil
      (@@instance/'instance/name').first.text.should_not == nil
      (@@instance/'instance/owner_id').first.text.should_not == ''
      (@@instance/'instance/owner_id').first.text.should == ENV['API_USER']
      (@@instance/'instance/state').first.text.should == 'PENDING'
    end

    def test_01_02_it_can_create_instance_with_hardware_profile
      params = {
        :image_id => '71',
        :hwp_id => '2',
        :'api[driver]' => 'rackspace',
      }
      header 'Accept', accept_header(:xml)
      post '/api/instances', params, authenticate
      last_response.status.should == 201 # Created
      @@instance2 = Nokogiri::XML(last_response.body)
      (@@instance2/'instance').length.should > 0
      (@@instance2/'instance/name').first.text.should_not == nil
      (@@instance2/'instance/name').first.text.should_not == nil
      (@@instance2/'instance/owner_id').first.text.should_not == ''
      (@@instance2/'instance/owner_id').first.text.should == ENV['API_USER']
      (@@instance2/'instance/state').first.text.should == 'PENDING'
    end

    def test_02_01_created_instance_has_correct_authentication
      (@@instance/'instance/authentication').first.should_not == nil
      (@@instance/'instance/authentication').first[:type].should == 'password'
      (@@instance/'instance/authentication/login/username').first.text.should == 'root'
      (@@instance/'instance/authentication/login/password').first.text.should_not == nil
      (@@instance/'instance/authentication/login/password').first.text.should_not == ''
    end

    def test_02_02_created_instance_has_correct_authentication
      (@@instance2/'instance/authentication').first.should_not == nil
      (@@instance2/'instance/authentication').first[:type].should == 'password'
      (@@instance2/'instance/authentication/login/username').first.text.should == 'root'
      (@@instance2/'instance/authentication/login/password').first.text.should_not == nil
      (@@instance2/'instance/authentication/login/password').first.text.should_not == ''
    end

    def test_03_01_created_instance_has_correct_addresses
      (@@instance/'instance/public_addresses/address').length.should > 0
      (@@instance/'instance/public_addresses/address').first.text.should_not == nil
      (@@instance/'instance/public_addresses/address').first.text.should_not == ''
    end

    def test_03_02_created_instance_has_correct_addresses
      (@@instance2/'instance/public_addresses/address').length.should > 0
      (@@instance2/'instance/public_addresses/address').first.text.should_not == nil
      (@@instance2/'instance/public_addresses/address').first.text.should_not == ''
    end

    def test_03_02_created_instance_has_correct_hardware_profile
      (@@instance2/'instance/hardware_profile').length.should == 1
      (@@instance2/'instance/hardware_profile').first[:id].should == "2"
      (@@instance2/'instance/hardware_profile').first[:href].should_not == nil
    end

    def test_04_01_created_instance_goes_to_running_state
      20.times do
        do_xml_request "/api;driver=rackspace/instances/#{(@@instance/'instance').first[:id]}", {}, true
        last_response.status.should_not == 500
        state = (last_xml_response/'instance/state').first.text
        break if state=='RUNNING'
        sleep(5)
      end
      @@instance = last_xml_response
      do_xml_request "/api;driver=rackspace/instances/#{(@@instance/'instance').first[:id]}", {}, true
      last_response.status.should_not == 500
      (last_xml_response/'instance/state').first.text.should == 'RUNNING'
      (last_xml_response/'instance/actions/link[@rel="reboot"]').first.should_not == nil
      (last_xml_response/'instance/actions/link[@rel="stop"]').first.should_not == nil
      (last_xml_response/'instance/actions/link[@rel="create_image"]').first.should_not == nil
      (last_xml_response/'instance/actions/link[@rel="run"]').first.should_not == nil
    end

    def test_04_02_created_instance_goes_to_running_state
      20.times do
        do_xml_request "/api;driver=rackspace/instances/#{(@@instance2/'instance').first[:id]}", {}, true
        last_response.status.should_not == 500
        state = (last_xml_response/'instance/state').first.text
        break if state=='RUNNING'
        sleep(5)
      end
      @@instance2 = last_xml_response
      do_xml_request "/api;driver=rackspace/instances/#{(@@instance2/'instance').first[:id]}", {}, true
      last_response.status.should_not == 500
      (last_xml_response/'instance/state').first.text.should == 'RUNNING'
      (last_xml_response/'instance/actions/link[@rel="reboot"]').first.should_not == nil
      (last_xml_response/'instance/actions/link[@rel="stop"]').first.should_not == nil
      (last_xml_response/'instance/actions/link[@rel="create_image"]').first.should_not == nil
      (last_xml_response/'instance/actions/link[@rel="run"]').first.should_not == nil
    end

    def test_05_created_instance_can_be_rebooted
      params = {
        :'api[driver]' => 'rackspace',
      }
      header 'Accept', accept_header(:xml)
      post "/api/instances/#{(@@instance/'instance').first[:id]}/reboot", params, authenticate
      last_response.status.should == 200
      20.times do
        do_xml_request "/api;driver=rackspace/instances/#{(@@instance/'instance').first[:id]}", {}, true
        last_response.status.should_not == 500
        state = (last_xml_response/'instance/state').first.text
        break if state=='RUNNING'
        sleep(5)
      end
    end

    def test_06_created_instance_can_be_destroyed
      params = {
        :'api[driver]' => 'rackspace',
      }
      header 'Accept', accept_header(:xml)
      post "/api/instances/#{(@@instance/'instance').first[:id]}/stop", params, authenticate
      last_response.status.should == 200
      20.times do
        do_xml_request "/api;driver=rackspace/instances/#{(@@instance/'instance').first[:id]}", {}, true
        last_response.status.should_not == 500
        break if last_response.status == 404
        sleep(5)
      end
      last_response.status.should == 404
    end

    def test_06_02_created_instance_can_be_destroyed
      params = {
        :'api[driver]' => 'rackspace',
      }
      header 'Accept', accept_header(:xml)
      post "/api/instances/#{(@@instance2/'instance').first[:id]}/stop", params, authenticate
      last_response.status.should == 200
      20.times do
        do_xml_request "/api;driver=rackspace/instances/#{(@@instance2/'instance').first[:id]}", {}, true
        last_response.status.should_not == 500
        break if last_response.status == 404
        sleep(5)
      end
      last_response.status.should == 404
    end

  end
end
