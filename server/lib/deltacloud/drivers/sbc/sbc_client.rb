#
# Copyright (C) 2011 IBM Corporation
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

require 'base64'
require 'net/https'
require 'json'

module Deltacloud
  module Drivers
    module SBC
#
# Client for the IBM Smart Business Cloud (SBC).
#
# 31 January 2011
#
class SBCClient
  API_URL = URI.parse('https://www-147.ibm.com/computecloud/enterprise/api/rest/20100331')

  #
  # Initialize the client
  #
  def initialize(username, password)
    @username, @password = username, password
    @rest_base = '/computecloud/enterprise/api/rest/20100331'
    @service = Net::HTTP.new(API_URL.host, API_URL.port)
    @service.use_ssl = true
  end

  #
  # Retrieve instances
  #
  def list_instances(instance_id=nil)
    if instance_id.nil?
      JSON.parse(get('/instances', default_headers))['instances']
    else
      [ JSON.parse(get('/instances/' + instance_id, default_headers)) ]
    end
  end

  #
  # Reboot an instance
  #
  def reboot_instance(instance_id)
    headers = default_headers
    headers['Content-Type'] = 'application/x-www-form-urlencoded'
    put('/instances/' + instance_id, 'state=restart', headers)
  end

  #
  # Delete an instance
  #
  def delete_instance(instance_id)
    delete('/instances/' + instance_id, default_headers)
  end

  #
  # Retrieve images
  #
  def list_images(image_id=nil)
    if image_id.nil?
      JSON.parse(get('/offerings/image', default_headers))['images']
    else
      [ JSON.parse(get('/offerings/image/' + image_id, default_headers)) ]
    end
  end

  #
  # Retrieve locations; returns an XML document.
  #
  def list_locations
    headers = default_headers
    headers['Accept'] = 'text/xml'	# JSON locations not supported
    Nokogiri.XML(get('/locations', headers))
  end

  #
  # Creates an instance
  #
  # body is a name/value hash to configure the instance
  #
  def create_instance(body)
    headers = default_headers
    headers['Content-Type'] = 'application/x-www-form-urlencoded'
    JSON.parse(post('/instances', urlencode(body), headers))['instances']
  end

  #
  # -------------------- Private Helpers -----------------
  #
  private

  #
  # HTTP GET
  #
  def get(path, headers)
    resp = @service.get(@rest_base + path, headers)
    unless resp.is_a?(Net::HTTPSuccess)
      backend_error!(resp)
    end
    resp.body
  end

  #
  # HTTP PUT
  #
  def put(path, body, headers)
    resp = @service.put(@rest_base + path, body, headers)
    unless resp.is_a?(Net::HTTPSuccess)
      backend_error!(resp)
    end
    resp.body
  end

  #
  # HTTP POST
  #
  def post(path, body, headers)
    resp = @service.post(@rest_base + path, body, headers)
    unless resp.is_a?(Net::HTTPSuccess)
      backend_error!(resp)
    end
    resp.body
  end

  #
  # HTTP DELETE
  #
  def delete(path, headers)
    resp = @service.delete(@rest_base + path, headers)
    unless resp.is_a?(Net::HTTPSuccess)
      backend_error!(resp)
    end
    resp.body
  end

  #
  # Default request headers.
  #
  def default_headers
    {"Accept" => "application/json",
      "User-Agent" => "deltacloud",
      "Authorization" => "Basic " + Base64.encode64("#{@username}:#{@password}")}
  end

  #
  # Handle request error
  #
  def backend_error!(resp)
    if resp.is_a?(Net::HTTPUnauthorized)
      raise Deltacloud::AuthException, resp.message
    else
      raise Deltacloud::BackendError.new(resp.code, resp.body, resp.message, '')
    end
  end

  #
  # Utility to URL encode a hash.
  #
  def urlencode(hash)
    hash.keys.map { |k| "#{URI.encode(k)}=#{URI.encode(hash[k])}" }.join("&")
  end
end
    end
  end
end
