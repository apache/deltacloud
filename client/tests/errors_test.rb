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

require 'rubygems'
require 'require_relative' if RUBY_VERSION =~ /^1\.8/

require_relative './test_helper.rb'

describe "server error handler" do

  it 'should capture HTTP 500 error as DeltacloudError' do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      lambda { client.realm('500') }.must_raise DeltaCloud::HTTPError::DeltacloudError
    end
  end

  it 'should capture HTTP 502 error as ProviderError' do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      lambda { client.realm('502') }.must_raise DeltaCloud::HTTPError::ProviderError
    end
  end

  it 'should capture HTTP 501 error as NotImplemented' do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      lambda { client.realm('501') }.must_raise DeltaCloud::HTTPError::NotImplemented
    end
  end

  it 'should capture HTTP 504 error as ProviderTimeout' do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      lambda { client.realm('504') }.must_raise DeltaCloud::HTTPError::ProviderTimeout
    end
  end

end

describe "client error handler" do

  it 'should capture HTTP 404 error as NotFound' do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      lambda { client.realm('non-existing-realm') }.must_raise DeltaCloud::HTTPError::NotFound
    end
  end

end
