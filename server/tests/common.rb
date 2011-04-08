# Copyright (C) 2009-2011  Red Hat, Inc.
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
#

$:.unshift File.join(File.dirname(__FILE__), '..')

require 'rubygems'
require 'yaml'
require 'base64'
require 'test/unit'
require 'spec'
require 'nokogiri'
require 'json'

# Set proper environment variables for running test

ENV['RACK_ENV']     = 'test'
ENV['API_HOST']     = 'localhost'
ENV['API_PORT']     = '4040'

require 'server'

configure :test do
  set :loggining, false
  set :clean_trace, false
  set :dump_errors, true
  set :raise_errors => false
  set :show_exceptions, false
end

require 'rack/test'
require 'digest/sha1'

Spec::Runner.configure do |conf|
  conf.include Rack::Test::Methods
end

module DeltacloudTestCommon

  def recording?
    @use_recording
  end

  def record!
    @use_recording = true
  end


  # Authentication helper for Basic HTTP authentication
  # To change default user credentials stored in ENV['API_USER|PASSWORD'] you
  # need to set opts[:credentials] = { :user => '...', :password => '...'}
  #
  def authenticate(opts={})
    credentials = opts[:credentials] || { :user => ENV['API_USER'], :password => ENV['API_PASSWORD']}
    return {
      'HTTP_AUTHORIZATION' => "Basic " + Base64.encode64("#{credentials[:user]}:#{credentials[:password]}")
    }
  end

  # HTTP Accept header helper.
  # Will set appropriate value for this header.
  # Available options for format are: :json, :html or :xml
  # By default :xml is used
  #
  def accept(format=:xml)
    case format
      when :json then 'application/json;q=0.9'
      when :html then 'text/html;q=0.9'
      when :xml then 'application/xml;q=0.9'
      else 'application/xml;q=0.9'
    end
  end

  # This helper will execute GET operation on given URI.
  # You can set additional parameters using params Hash, which will be passed to
  # request.
  # You can change format used for communication using opts[:format] = :xml | :html :json
  # You can turn on recording (you need to configure it first in setup.rb) using
  # opts[:record] (true/false)
  # You can force authentication using opts[:auth] parameter or use
  # 'get_auth_url' which will do it for you ;-)
  #
  def get_url(uri, params={}, opts={})
    header 'Accept', accept(opts[:format] || :xml)
    if DeltacloudTestCommon::recording?
      VCR.use_cassette("get-" + Digest::SHA1.hexdigest("#{uri}-#{params}}")) do
        get(uri, params || {}, opts[:auth] ? authenticate(opts) : {})
      end
    else
      get(uri, params || {}, opts[:auth] ? authenticate(opts) : {})
    end
    last_response.status.should_not == 401
  end

  def get_auth_url(uri, params={}, opts={})
    opts.merge!(:auth => true)
    get_url(uri, params, opts)
  end

  def post_url(uri, params={}, opts={})
    header 'Accept', accept(opts[:format] || :xml)
    if DeltacloudTestCommon::recording?
      VCR.use_cassette("post-" + Digest::SHA1.hexdigest("#{uri}-#{params}")) do
        post(uri, params || {}, authenticate(opts))
      end
    else
        post(uri, params || {}, authenticate(opts))
    end
  end

  def delete_url(uri, params={}, opts={})
    header 'Accept', accept(opts[:format] || :xml)
    if DeltacloudTestCommon::recording?
      VCR.use_cassette("delete-"+Digest::SHA1.hexdigest("#{uri}-#{params}")) do
        delete(uri, params || {}, authenticate(opts))
      end
    else
        delete(uri, params || {}, authenticate(opts))
    end
  end

  def put_url(uri, params={}, opts={})
    header 'Accept', accept(opts[:format] || :xml)
    if DeltacloudTestCommon::recording?
      VCR.use_cassette("put-"+Digest::SHA1.hexdigest("#{uri}-#{params}-#{authenticate(opts)}")) do
        put(uri, params || {}, authenticate(opts))
      end
    else
        put(uri, params || {}, authenticate(opts))
    end
  end

  # This helper will automatically convert output from method above to Nokogiri
  # XML object
  def last_xml_response
    Nokogiri::XML(last_response.body) #if last_response.status.to_s =~ /2(\d+)/
  end

  # Check if given URI require authentication
  def require_authentication?(uri)
    get uri, {}
    true if last_response.status == 401
  end

  def with_provider(new_provider, &block)
    old_provider = ENV["API_PROVIDER"]
    begin
      ENV["API_PROVIDER"] = new_provider
      yield
    ensure
      ENV["API_PROVIDER"] = old_provider
    end
  end

  def add_created_instance(id)
    $created_instances ||= []
    $created_instances << id
  end

end

include DeltacloudTestCommon
