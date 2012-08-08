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

describe "server error handler" do

  it_should_behave_like "all resources"

  it 'should capture HTTP 500 error as DeltacloudError' do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      expect { client.realm('500') }.should raise_error(DeltaCloud::HTTPError::DeltacloudError)
    end
  end

  it 'should capture HTTP 502 error as ProviderError' do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      expect { client.realm('502') }.should raise_error(DeltaCloud::HTTPError::ProviderError)
    end
  end

  it 'should capture HTTP 501 error as NotImplemented' do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      expect { client.realm('501') }.should raise_error(DeltaCloud::HTTPError::NotImplemented)
    end
  end

  it 'should capture HTTP 504 error as ProviderTimeout' do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      expect { client.realm('504') }.should raise_error(DeltaCloud::HTTPError::ProviderTimeout)
    end
  end

end

describe "client error handler" do

  it 'should capture HTTP 404 error as NotFound' do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      expect { client.realm('non-existing-realm') }.should raise_error(DeltaCloud::HTTPError::NotFound)
    end
  end

end
