#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

$:.unshift File.join(File.dirname(__FILE__), '..')
require "deltacloud/test_setup.rb"

INSTANCES = "/instances"

describe 'Deltacloud API instances collection' do
  include Deltacloud::Test::Methods
  need_collection :instances
  #make sure we have at least one instance to test
  if collection_supported :instances
    #keep track of what we create for deletion after tests:
    @@created_resources = {:instances=>[], :keys=>[], :images=>[], :firewalls=>[]}
    image_id = get_a("image")
    res = post(INSTANCES, :image_id=>image_id)
    unless res.code == 201
      raise Exception.new("Failed to create instance from image_id #{image_id}")
    end
    @@my_instance_id = (res.xml/'instance')[0][:id]
    @@created_resources[:instances] << @@my_instance_id
  end

  #stop/destroy the resources we created for the tests
  MiniTest::Unit.after_tests {
puts "CLEANING UP... resources for deletion: #{@@created_resources.inspect}"
    #instances:
    @@created_resources[:instances].each_index do |i|
      attempts = 0
      begin
        stop_res = post(INSTANCES+"/"+@@created_resources[:instances][i]+"/stop", "")
        @@created_resources[:instances][i] = nil if stop_res.code == 202
      rescue Exception => e
        sleep(10)
        attempts += 1
        retry if (attempts <= 5)
      end
    end
    @@created_resources[:instances].compact!
    @@created_resources.delete(:instances) if @@created_resources[:instances].empty?
    #keys
    [:keys, :images, :firewalls].each do |col|
      @@created_resources[col].each do |k|
        attempts = 0
        begin
          res = delete("/#{col}/#{k}")
          @@created_resources[col].delete(k) if res.code == 204
        rescue Exception => e
          sleep(10)
          attempts += 1
          retry if (attempts <=5)
        end
      end
      @@created_resources.delete(col) if @@created_resources[col].empty?
    end
puts "CLEANUP attempt finished... resources looks like: #{@@created_resources.inspect}"
    raise Exception.new("Unable to delete all created resources - please check: #{@@created_resources.inspect}") unless @@created_resources.empty?
  }

  def each_instance_xml(&block)
    res = get(INSTANCES)
    (res.xml/'instances/instance').each do |r|
      instance_res = get(INSTANCES + '/' + r[:id])
      yield instance_res.xml
    end
  end

  #Run the 'common' tests for all collections defined in common_tests_collections.rb
  CommonCollectionsTest::run_collection_and_member_tests_for("instances")

  #Now run the instances-specific tests:

  it 'must have a legal "state" element defined for each instance in collection, or no "state" at all' do
    res = get(INSTANCES)
    (res.xml/'instances/instance').each do |r|
      # provider may not return state for each instance in collection because of performance reasons
      (r/'state').first.must_match /(RUNNING|STOPPED|PENDING)/ unless (r/'state').empty?
    end
  end

  it 'must have the "owner_id" element for each instance and it should match with the one in collection' do
    res = get(INSTANCES)
    (res.xml/'instances/instance').each do |r|
      instance_res = get(INSTANCES + '/' + r[:id])
      (instance_res.xml/'owner_id').wont_be_empty
      (instance_res.xml/'owner_id').first.text.must_equal((r/'owner_id').first.text)
    end
  end

  it 'each instance must link to the realm that was used during instance creation' do
    each_instance_xml do |instance_xml|
      (instance_xml/'realm').wont_be_empty
      (instance_xml/'realm').size.must_equal 1
      (instance_xml/'realm').first[:id].wont_be_nil
      (instance_xml/'realm').first[:href].wont_be_nil
      (instance_xml/'realm').first[:href].must_match /\/#{(instance_xml/'realm').first[:id]}$/
    end
  end

  it 'each instance must link to the image that was used to during instance creation' do
    each_instance_xml do |instance_xml|
      (instance_xml/'image').wont_be_empty
      (instance_xml/'image').size.must_equal 1
      (instance_xml/'image').first[:id].wont_be_nil
      (instance_xml/'image').first[:href].wont_be_nil
      (instance_xml/'image').first[:href].must_match /\/#{(instance_xml/'image').first[:id]}$/
    end
  end

  it 'each instance must link to the hardware_profile that was used to during instance creation' do
    each_instance_xml do |instance_xml|
      (instance_xml/'hardware_profile').wont_be_empty
      (instance_xml/'hardware_profile').size.must_equal 1
      (instance_xml/'hardware_profile').first[:id].wont_be_nil
      (instance_xml/'hardware_profile').first[:href].wont_be_nil
      (instance_xml/'hardware_profile').first[:href].must_match /\/#{(instance_xml/'hardware_profile').first[:id]}$/
    end
  end

  it 'each (NON-STOPPED) instance should advertise the public and private addresses of the instance' do
    each_instance_xml do |instance_xml|
      #skip this instance if it is in STOPPED state
      next if (instance_xml/'instance/state').text == "STOPPED"
      (instance_xml/'public_addresses').wont_be_empty
      (instance_xml/'public_addresses').size.must_equal 1
      (instance_xml/'public_addresses/address').each do |a|
        a[:type].wont_be_nil
        a.text.strip.wont_be_empty
      end
      (instance_xml/'private_addresses').wont_be_empty
      (instance_xml/'private_addresses').size.must_equal 1
      (instance_xml/'private_addresses/address').each do |a|
        a[:type].wont_be_nil
        a.text.strip.wont_be_empty
      end
    end
  end

  it 'each instance should advertise the storage volumes used by the instance' do
      each_instance_xml do |i|
        (i/'storage_volumes').wont_be_empty
      end
  end

  it 'each instance should advertise the list of actions that can be executed for each instance' do
    each_instance_xml do |instance_xml|
      (instance_xml/'actions/link').each do |l|
        l[:href].wont_be_nil
        l[:href].must_match /^http/
        l[:method].wont_be_nil
        l[:rel].wont_be_nil
      end
    end
  end

  it 'should allow to create new instance using image without realm' do
    #random image and create instance
    image_id = get_a("image")
    image_id.wont_be_nil
    res = post(INSTANCES, :image_id=>image_id)
    res.code.must_equal 201
    res.headers[:location].wont_be_nil
    created_instance_id = (res.xml/'instance')[0][:id]
    #GET the instance
    res = get(INSTANCES+"/"+created_instance_id)
    res.code.must_equal 200
    (res.xml/'instance').first[:id].must_equal created_instance_id
    (res.xml/'instance/image').first[:id].must_equal image_id
    #mark it for stopping after tests run:
    @@created_resources[:instances] << created_instance_id
  end

  it 'should allow to create new instance using image and realm' do
    #random image, realm and create instance
    image_id = get_a("image")
    image_id.wont_be_nil
    realm_id = get_a("realm")
    realm_id.wont_be_nil
    res = post(INSTANCES, :image_id=>image_id, :realm_id=>realm_id)
    res.code.must_equal 201
    res.headers[:location].wont_be_nil
    created_instance_id = (res.xml/'instance')[0][:id]
    #GET the instance
    res = get(INSTANCES+"/"+created_instance_id)
    res.code.must_equal 200
    (res.xml/'instance').first[:id].must_equal created_instance_id
    (res.xml/'instance/image').first[:id].must_equal image_id
    (res.xml/'instance/realm').first[:id].must_equal realm_id
    #mark it for stopping after tests run:
    @@created_resources[:instances] << created_instance_id
  end

  it 'should allow to create new instance using image, realm and hardware_profile' do
    #random image, realm, hardware_profile and create instance
    image_id = get_a("image")
    image_id.wont_be_nil
    #check if this image defines compatible hw_profiles:
    res = get("/images/"+image_id)
    if (res.xml/'image/hardware_profiles').empty?
      hwp_id = get_a("hardware_profile")
    else
      hwp_id = (res.xml/'image/hardware_profiles/hardware_profile').to_a.choice[:id]
    end
    hwp_id.wont_be_nil
    #random realm:
    realm_id = get_a("realm")
    realm_id.wont_be_nil
    res = post(INSTANCES, :image_id=>image_id, :realm_id=>realm_id, :hwp_id => hwp_id)
    res.code.must_equal 201
    res.headers[:location].wont_be_nil
    created_instance_id = (res.xml/'instance')[0][:id]
    #GET the instance
    res = get(INSTANCES+"/"+created_instance_id)
    res.code.must_equal 200
    (res.xml/'instance').first[:id].must_equal created_instance_id
    (res.xml/'instance/image').first[:id].must_equal image_id
    (res.xml/'instance/realm').first[:id].must_equal realm_id
    (res.xml/'instance/hardware_profile').first[:id].must_equal hwp_id
    #mark it for stopping after tests run:
    @@created_resources[:instances] << created_instance_id
  end

#snapshot (make image)

  it 'should allow to snapshot running instance if supported by provider' do
    #check if created instance allows creating image
    res = get(INSTANCES+"/"+@@my_instance_id)
    instance_actions = (res.xml/'actions/link').to_a.inject([]){|actions, current| actions << current[:rel]; actions}
    skip "no create image support for instance #{@@my_instance_id}" unless instance_actions.include?("create_image")
    #create image
    res = post("/images", :instance_id => @@my_instance_id, :name => random_name)
    res.code.must_equal 201
    my_image_id = (res.xml/'image')[0][:id]
    #mark for deletion later:
    @@created_resources[:images] << my_image_id
  end
#
#create with key

  describe "create instance with auth key" do

    need_collection :keys
    need_feature :instances, :authentication_key

      it 'should allow specification of auth key for created instance when supported' do
        #create a key to use
        key_name = random_name
        key_res = post("/keys", :name=>key_name)
        key_res.code.must_equal 201
        key_id = (key_res.xml/'key')[0][:id]
        #create instance with this key:
        image_id = get_a("image")
        res = post(INSTANCES, :image_id => image_id, :keyname => key_id)
        res.code.must_equal 201
        instance_id = (res.xml/'instance')[0][:id]
        #check the key:
        key_used = (res.xml/'instance/authentication/login/keyname')[0].text
        key_used.must_equal key_id
        #mark them for deletion after tests run:
        @@created_resources[:instances] << instance_id
        @@created_resources[:keys] << key_id
    end

  end

#specify user name (feature)
  describe "create instance with user defined name" do

    need_feature :instances, :user_name

    it 'should allow specification of name for created instance when supported' do
      instance_name = random_name
      image_id = get_a("image")
      res = post(INSTANCES, :image_id => image_id, :name => instance_name)
      res.code.must_equal 201
      instance_id = (res.xml/'instance')[0][:id]
      #check the name:
      created_name = (res.xml/'instance/name')[0].text
      created_name.must_equal instance_name
      #mark for deletion:
      @@created_resources[:instances] << instance_id
    end
  end

#create with firewall (feature)
  describe "create instance with firewall" do

    need_collection :firewalls
    need_feature :instances, :firewalls

    it 'should be able to create instance using specified firewall' do
        #create a firewall to use
        fw_name = random_name
        fw_res = post("/firewalls", :name=>fw_name, :description=>"firewall created for instances API test on #{Time.now}")
        fw_res.code.must_equal 201
        fw_id = (fw_res.xml/'firewall')[0][:id]
        ((fw_res.xml/'firewall/name')[0].text).must_equal fw_name
        #create instance with this firewall:
        image_id = get_a("image")
        res = post(INSTANCES, :image_id => image_id, :firewalls1 => fw_id)
        res.code.must_equal 201
        instance_id = (res.xml/'instance')[0][:id]
        #check the firewall:
        fw_used = (res.xml/'instance/firewalls/firewall')[0][:id]
        fw_used.must_equal fw_id
        #mark for deletion:
        @@created_resources[:instances] << instance_id
        @@created_resources[:firewalls] << fw_id
    end

  end
end
