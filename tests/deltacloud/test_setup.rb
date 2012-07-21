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

# Make a GET request for +path+ and return the +RestClient::Response+. The
# query string for the request is generated from +params+, with the
# exception of a few special entries in params, which are used to set some
# headers, and will not appear in the query string:
#
#   :noauth          : do not send an auth header
#   :user, :password : use these for the auth header
#   :accept          : can be :xml or :json, and sets the Accept header
#   :driver, :provider : set driver and/or provider with the appropriate header
#
# If none of the auth relevant params are set, use the username and
# password for the current driver from the config
def get(path, params={})
  url, headers = process_url_params(path, params)
  RestClient.get url, headers
end

def post(path, post_body, params={})
  url, headers = process_url_params(path, params)
  RestClient.post url, post_body, headers
end

def delete(path, params={})
  url, headers = process_url_params(path, params)
  RestClient.delete url, headers
end

def options(path, params={})
  url, headers = process_url_params(path, params)
  RestClient.options url, headers
end

# Should be private
def process_url_params(path, params)
  path = "" if path == "/"
  headers = {}
  unless params.delete(:noauth)
    if params[:user]
      u = params.delete(:user)
      p = params.delete(:password)
      headers['Authorization'] = "Basic #{Base64.encode64("#{u}:#{p}")}"
    else
      headers['Authorization'] = BASIC_AUTH
    end
  end
  headers["X-Deltacloud-Driver"] = params.delete(:driver) if params[:driver]
  headers["X-Deltacloud-Provider"] = params.delete(:provider) if params[:providver]
  headers["Accept"] = "application/#{params.delete(:accept)}" if params[:accept]

  if path =~ /^https?:/
    url = path
  else
    url = API_URL + path
  end
  url += "?" + params.map { |k,v| "#{k}=#{v}" }.join("&") unless params.empty?
  if ENV["LOG"] && ENV["LOG"].include?("requests")
    puts "GET #{url}"
    headers.each { |k, v| puts "#{k}: #{v}" }
  end
  [url, headers]
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

def random_name
  name = rand(36**10).to_s(36)
  name.insert(0, "apitest")
end

def discover_features
  res = xml_response(get("/"))
  features_hash = res.xpath("//api/link").inject({}) do |result, collection|
    result.merge!({collection[:rel] => []})
    collection.children.inject([]){|features, current_child| result[collection[:rel]] << current_child[:name] if current_child.name == "feature"}
    result
  end
end
