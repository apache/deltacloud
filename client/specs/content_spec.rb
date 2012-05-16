#
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

require 'specs/spec_helper'

def client
  RestClient::Resource.new(API_URL)
end

def headers(header)
  encoded_credentials = ["#{API_NAME}:#{API_PASSWORD}"].pack("m0").gsub(/\n/,'')
  { :authorization => "Basic " + encoded_credentials }.merge(header)
end

describe "return JSON" do

  it 'should return JSON when using application/json, */*' do
    header_hash = {
      # FIXME: There is a bug in rack-accept that cause to respond with HTML
      # to the configuration below.
      #
      # 'Accept' => "application/json, */*"
      'Accept' => "application/json"
    }
    client.get(header_hash) do |response, request, &block|
      response.code.should == 200
      response.headers[:content_type].should =~ /^application\/json/
    end
  end

  it 'should return JSON when using just application/json' do
    header_hash = {
      'Accept' => "application/json"
    }
    client.get(header_hash) do |response, request, &block|
      response.code.should == 200
      response.headers[:content_type].should =~ /^application\/json/
    end
  end

end

describe "return HTML in different browsers" do

  it "wants XML using format parameter" do
    client.get(:params => { 'format' => 'xml' }, 'Accept' => 'application/xhtml+xml') do |response, request, &block|
      response.code.should == 200
      response.headers[:content_type].should =~ /^application\/xml/
    end
  end

  it "raise 406 error on wrong accept" do
    client['hardware_profiles'].get('Accept' => 'image/png;q=1') do |response, request, &block|
      response.code.should == 406
    end
  end

  it "wants HTML using format parameter and accept set to XML" do
    client.get(:params => { 'format' => 'html'}, 'Accept' => 'application/xml') do |response, request, &block|
      response.code.should == 200
      response.headers[:content_type].should =~ /^text\/html/
    end
  end

#  FIXME: This return 406 for some reason on GIT sinatra
#  it "wants a PNG image" do 
#    client['instance_states'].get('Accept' => 'image/png') do |response, request, &block|
#      response.code.should == 200
#      response.headers[:content_type].should =~ /^image\/png/
#    end
#  end

  it "doesn't have accept header" do
    client.get('Accept' => '') do |response, request, &block|
      response.code.should == 200
      response.headers[:content_type].should =~ /^application\/xml/
    end
  end

  it "can handle unknown formats" do
    client.get('Accept' => 'format/unknown') do |response, request, &block|
      response.code.should == 406
    end
  end

  it "wants explicitly XML" do
    client.get('Accept' => 'application/xml') do |response, request, &block|
      response.code.should == 200
      response.headers[:content_type].should =~ /^application\/xml/
    end
  end

  it "Internet Explorer" do
    header_hash = {
      'Accept' => "image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/x-ms-application, application/x-ms-xbap, application/vnd.ms-xpsdocument, application/xaml+xml, */*",
      'User-agent' => "Mozilla/5.0 (Windows; U; MSIE 9.0; Windows NT 9.0; en-US)"
    }
    client.get(header_hash) do |response, request, &block|
      response.code.should == 200
      response.headers[:content_type].should =~ /^text\/html/
    end
  end

  it "Mozilla Firefox" do
    client.get('Accept' => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8") do |response, request, &block|
      response.code.should == 200
      response.headers[:content_type].should =~ /^text\/html/
    end
  end

  it "Opera" do
    header_hash = { 
      'Accept' => "text/html, application/xml;q=0.9, application/xhtml+xml, image/png, image/jpeg, image/gif, image/x-xbitmap, */*;q=0.1",
      'User-agent' => "Opera/9.80 (X11; Linux i686; U; ru) Presto/2.8.131 Version/11.11"
    }
    client.get(header_hash) do |response, request, &block|
      response.code.should == 200
      response.headers[:content_type].should =~ /^text\/html/
    end
  end

end
