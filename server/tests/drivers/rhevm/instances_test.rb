$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/common'

module RHEVMTest

  class InstancesTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_01_01_it_can_create_instance_without_hardware_profile
      params = {
        :image_id => 'bb2e79bd-fd73-46a1-b391-a390b1998f03',
        :name => 'mock-test1',
        :'api[driver]' => 'rhevm',
      }
      post_url '/api/instances', params
      last_response.status.should == 201 # Created
      @@instance = last_xml_response
      (@@instance/'instance').length.should > 0
      (@@instance/'instance/name').first.text.should_not == nil
      (@@instance/'instance/name').first.text.should == 'mock-test1'
      (@@instance/'instance/owner_id').first.text.should_not == ''
      (@@instance/'instance/owner_id').first.text.should == ENV['API_USER']
      (@@instance/'instance/state').first.text.should == 'STOPPED'
    end

    def test_01_02_it_can_create_instance_with_hardware_profile
      params = {
        :image_id => 'bb2e79bd-fd73-46a1-b391-a390b1998f03',
        :name => 'mock-test2',
        :hwp_id => 'SERVER',
        :'api[driver]' => 'rhevm',
      }
      post_url '/api/instances', params
      last_response.status.should == 201 # Created
      @@instance2 = last_xml_response
      (@@instance2/'instance').length.should > 0
      (@@instance2/'instance/name').first.text.should_not == nil
      (@@instance2/'instance/name').first.text.should == 'mock-test2'
      (@@instance2/'instance/owner_id').first.text.should_not == ''
      (@@instance2/'instance/owner_id').first.text.should == ENV['API_USER']
      (@@instance2/'instance/state').first.text.should == 'STOPPED'
    end

    def test_03_02_created_instance_has_correct_hardware_profile
      (@@instance2/'instance/hardware_profile').length.should == 1
      (@@instance2/'instance/hardware_profile').first[:id].should == "SERVER"
      (@@instance2/'instance/hardware_profile').first[:href].should_not == nil
    end

    def test_03_01_instance_can_be_started
      params = {
        :'api[driver]' => 'rhevm'
      }
      post_url "/api/instances/#{(@@instance/'instance').first[:id]}/start", params
      last_response.status.should == 204
    end

    def test_04_01_created_instance_goes_to_running_state
      20.times do |tick|
        get_auth_url "/api;driver=rhevm/instances/#{(@@instance/'instance').first[:id]}", { :tick => tick}
        last_response.status.should_not == 500
        state = (last_xml_response/'instance/state').first.text
        break if state=='RUNNING'
        sleep(5)
      end
      @@instance = last_xml_response
      get_auth_url "/api;driver=rhevm/instances/#{(@@instance/'instance').first[:id]}"
      last_response.status.should_not == 500
      (last_xml_response/'instance/state').first.text.should == 'RUNNING'
      (last_xml_response/'instance/actions/link[@rel="reboot"]').first.should_not == nil
      (last_xml_response/'instance/actions/link[@rel="stop"]').first.should_not == nil
    end

    def test_03_02_instance_can_be_started
      params = {
        :'api[driver]' => 'rhevm'
      }
      post_url "/api/instances/#{(@@instance2/'instance').first[:id]}/start", params
      last_response.status.should == 204
    end

    def test_04_02_created_instance_goes_to_running_state
      20.times do |tick|
        get_auth_url "/api;driver=rhevm/instances/#{(@@instance2/'instance').first[:id]}", { :tick => tick}
        last_response.status.should_not == 500
        state = (last_xml_response/'instance/state').first.text
        break if state=='RUNNING'
        sleep(5)
      end
      @@instance2 = last_xml_response
      get_auth_url "/api;driver=rhevm/instances/#{(@@instance2/'instance').first[:id]}"
      last_response.status.should_not == 500
      (last_xml_response/'instance/state').first.text.should == 'RUNNING'
      (last_xml_response/'instance/actions/link[@rel="reboot"]').first.should_not == nil
      (last_xml_response/'instance/actions/link[@rel="stop"]').first.should_not == nil
    end

    def test_05_01_created_instance_can_be_stopped
      params = {
        :'api[driver]' => 'rhevm',
      }
      post_url "/api/instances/#{(@@instance/'instance').first[:id]}/stop", params
      last_response.status.should == 204
      20.times do |tick|
        get_auth_url "/api;driver=rhevm/instances/#{(@@instance/'instance').first[:id]}", { :tick => tick}
        last_response.status.should_not == 500
        state = (last_xml_response/'instance/state').first.text
        break if state=='STOPPED'
        sleep(5)
      end
    end

    def test_05_02_created_instance_can_be_stopped
      params = {
        :'api[driver]' => 'rhevm',
      }
      post_url "/api/instances/#{(@@instance2/'instance').first[:id]}/stop", params
      last_response.status.should == 204
      20.times do |tick|
        get_auth_url "/api;driver=rhevm/instances/#{(@@instance2/'instance').first[:id]}", { :tick => tick}
        last_response.status.should_not == 500
        state = (last_xml_response/'instance/state').first.text
        break if state=='STOPPED'
        sleep(5)
      end
    end

    def test_06_01_created_instance_can_be_destroyed
      params = {
        :'api[driver]' => 'rhevm',
      }
      delete_url "/api/instances/#{(@@instance/'instance').first[:id]}", params
      last_response.status.should == 204
      20.times do |tick|
        get_auth_url "/api;driver=rhevm/instances/#{(@@instance/'instance').first[:id]}", { :tick => tick}
        last_response.status.should_not == 500
        break if last_response.status == 404
        sleep(5)
      end
      last_response.status.should == 404
    end

    def test_06_02_created_instance_can_be_destroyed
      params = {
        :'api[driver]' => 'rhevm',
      }
      delete_url "/api/instances/#{(@@instance2/'instance').first[:id]}", params, authenticate
      last_response.status.should == 204
      20.times do |tick|
        get_auth_url "/api;driver=rhevm/instances/#{(@@instance2/'instance').first[:id]}", { :tick => tick}
        last_response.status.should_not == 500
        break if last_response.status == 404
        sleep(5)
      end
      last_response.status.should == 404
    end
  end
end
