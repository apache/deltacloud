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

require 'rubygems'
require 'minitest/autorun'
require 'rest_client'
require 'nokogiri'
require 'json'
require 'base64'
require 'yaml'

#SETUP
$:.unshift File.join(File.dirname(__FILE__), '..')
CONFIG = YAML.load(File.open("deltacloud/config.yaml"))
API_URL = CONFIG["api_url"]
API_DRIVER = RestClient.get(API_URL) do |response, request, result|
  Nokogiri::XML(response).root[:driver]
end
raise Exception.new("Can't find config for driver: #{API_DRIVER} currently running at #{API_URL} in config.yaml file") unless CONFIG[API_DRIVER] and CONFIG[API_DRIVER]["user"] and CONFIG[API_DRIVER]["password"]
USER    = CONFIG[API_DRIVER]["user"]
PASSWORD= CONFIG[API_DRIVER]["password"]
BASIC_AUTH="Basic #{Base64.encode64(USER+":"+PASSWORD)}"

DRIVERS = RestClient.get(API_URL+"/drivers") do |response, request, result|
  Nokogiri::XML(response).xpath("//driver/name").inject([]){|res, c| res << c.text.downcase; res}
end
API_VERSION = Nokogiri::XML(RestClient.get API_URL).root[:version]
#SETUP

def xml_response(xml)
  Nokogiri::XML(xml)
end

def json_response(json)
  JSON.parse(json)
end

def get(params={}, path="", authenticate = false)
  if authenticate
    params.merge!({:Authorization=>BASIC_AUTH})
  end
  RestClient.get API_URL+path, params
end

def post(post_body = "", path= "", params={}, authenticate = false)
  if authenticate
    params.merge!({:Authorization=>BASIC_AUTH})
  end
  RestClient.post API_URL+path, post_body, params
end

def delete(params={}, path = "", authenticate = true)
  if authenticate
    params.merge!({:Authorization=>BASIC_AUTH})
  end
  RestClient.delete API_URL+path, params
end

def options(params={}, path="", authenticate = false)
  if authenticate
    params.merge!({:Authorization=>BASIC_AUTH})
  end
  RestClient.options API_URL+path, params
end

#the TEST_FILES hash and deltacloud_test_file_names method
#which follows is used in the Rakefile for the rake test:deltacloud task
TEST_FILES =  { :images             => "images_test.rb",
  :realms             => "realms_test.rb",
  :hardware_profiles  => "hardware_profiles_test.rb",
  :instance_states    => "instance_states_test.rb",
  :instances          => "instances_test.rb",
  :keys               => "keys_test.rb",
  :firewalls          => "firewalls_test.rb",
  :addresses          => "addresses_test.rb",
  :load_balancers     => "load_balancers_test.rb",
  :storage_volumes    => "storage_volumes_test.rb",
  :storage_snapshots  => "storage_snapshots_test.rb",
  :buckets            => "buckets_test.rb"
}
#gets the list of collections from the server running at API_URL and translates those into file names accoring to TEST_FILES
def deltacloud_test_file_names
  driver_collections = xml_response(RestClient.get API_URL, {:accept=>:xml}).xpath("//api/link").inject([]){|res, current| res<<current[:rel].to_sym ;res}
  driver_collections.inject([]){|res, current| res << "deltacloud/#{TEST_FILES[current]}" if TEST_FILES[current] ;res}
end

def create_a_bucket_and_blob
  #random bucket and blob name - make sure starts with letter:
  bucket_name = random_name
  blob_name = random_name
  #create bucket:
  #  res = RestClient.post "#{API_URL}/buckets", {:name=>bucket_name}, {:Authorization=>BASIC_AUTH}
  res = post({:name=>bucket_name}, "/buckets", {}, true)
  raise Exception.new("unable to create bucket with name #{bucket_name} for bucket_test.rb") unless res.code == 201
  #create blob:
  res = RestClient.put "#{API_URL}/buckets/#{bucket_name}/#{blob_name}", "This is the test blob content", {:Authorization=>BASIC_AUTH, :content_type=>"text/plain", "X-Deltacloud-Blobmeta-Version"=>"1.0", "X-Deltacloud-Blobmeta-Author"=>"herpyderp"}
  raise Exception.new("unable to create blob with name #{blob_name} for bucket_test.rb") unless res.code == 200
  return [bucket_name, blob_name]
end

def random_name
  name = rand(36**10).to_s(36)
  name.insert(0, "apitest")
end

def delete_bucket_and_blob(bucket, blob)
  #  res = RestClient.delete "#{API_URL}/buckets/#{bucket}/#{blob}", {:Authorization=>BASIC_AUTH}
  res = delete({}, "/buckets/#{bucket}/#{blob}")
  raise Exception.new("unable to delete blob with name #{blob} for bucket_test.rb") unless res.code == 204
  #  res = RestClient.delete "#{API_URL}/buckets/#{bucket}", {:Authorization=>BASIC_AUTH}
  res = delete({}, "/buckets/#{bucket}")
  raise Exception.new("unable to delete bucket with name #{bucket} for bucket_test.rb") unless res.code == 204
end

def discover_features
  res = xml_response(get)
  features_hash = res.xpath("//api/link").inject({}) do |result, collection|
    result.merge!({collection[:rel] => []})
    collection.children.inject([]){|features, current_child| result[collection[:rel]] << current_child[:name] if current_child.name == "feature"}
    result
  end
end
