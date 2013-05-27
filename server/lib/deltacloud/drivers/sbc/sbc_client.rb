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

module Deltacloud
  module Drivers
    module Sbc

class FixtureNotFound < Exception; end

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
    if ENV['RACK_ENV'] == 'test'
      mock_request(:get, path, {}, headers)
    else
      resp = @service.get(@rest_base + path, headers)
      unless resp.is_a?(Net::HTTPSuccess)
        backend_error!(resp)
      end
      resp.body
    end
  end

  #
  # HTTP PUT
  #
  def put(path, body, headers)
    if ENV['RACK_ENV'] == 'test'
      mock_request(:get, path, {}, headers)
    else
      resp = @service.put(@rest_base + path, body, headers)
      unless resp.is_a?(Net::HTTPSuccess)
        backend_error!(resp)
      end
      resp.body
    end
  end

  #
  # HTTP POST
  #
  def post(path, body, headers)
    if ENV['RACK_ENV'] == 'test'
      mock_request(:get, path, {}, headers)
    else
      resp = @service.post(@rest_base + path, body, headers)
      unless resp.is_a?(Net::HTTPSuccess)
        backend_error!(resp)
      end
      resp.body
    end
  end

  #
  # HTTP DELETE
  #
  def delete(path, headers)
    if ENV['RACK_ENV'] == 'test'
      mock_request(:get, path, {}, headers)
    else
      resp = @service.delete(@rest_base + path, headers)
      unless resp.is_a?(Net::HTTPSuccess)
        backend_error!(resp)
      end
      resp.body
    end
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
      raise "AuthFailure"
    else
      raise "BackendError"
    end
  end

  #
  # Utility to URL encode a hash.
  #
  def urlencode(hash)
    hash.keys.map { |k| "#{URI.encode(k)}=#{URI.encode(hash[k])}" }.join("&")
  end

  #
  # Reads a fake URL from local fixtures
  #
  def read_fake_url(filename)
    fixture_file = "../tests/sbc/support/fixtures/#{filename}"
    if File.exists?(fixture_file)
      return JSON::parse(File.read(fixture_file))
    else
      raise FixtureNotFound.new
    end
  end

  #
  # Executes a fake request from local fixtures
  #
  def mock_request(*args)
    http_method, request_uri, params, headers = args[0].to_sym, args[1], args[2], args[3]
    params ||= {}
    fixture_filename = fixture_filename = "#{Digest::MD5.hexdigest("#{http_method}#{request_uri}#{params.inspect}#{headers.reject{|key, value| key == "Authorization"}}")}.fixture"
    begin
      return read_fake_url(fixture_filename)[2]["body"]
    rescue FixtureNotFound
      if http_method.eql?(:get)
        r = @service.get(@rest_base + request_uri, headers)
      elsif http_method.eql?(:post)
        r = @service.post(@rest_base + request_uri, body, headers)
      elsif http_method.eql?(:put)
        r = @service.put(@rest_base + request_uri, params, headers)
      elsif http_method.eql?(:delete)
        r = @service.delete(@rest_base + request_uri, headers)
      end
      response = {
        "body" => r.body,
        "status" => r.code,
        "Content-Type" => r["Content-Type"]
      }
      fixtures_dir = "../tests/sbc/support/fixtures/"
      FileUtils.mkdir_p(fixtures_dir)
      File.open(File::join(fixtures_dir, fixture_filename), 'w') do |f|
        f.puts [request_uri, http_method, response].to_json
      end
      retry
    end
  end

end
    end
  end
end
