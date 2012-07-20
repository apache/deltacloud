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

describe "Deltacloud API Entry Point" do

  it 'return status 200 OK when accessing API entrypoint' do
    res = get
    res.code.must_equal 200
  end

  it 'advertise the current driver in API entrypoint' do
    res = get({:accept => :xml})
    driver = xml_response(res).root[:driver]
    driver.wont_be_nil
    DRIVERS.include?(driver).must_equal true
  end

  it 'advertise the current API version in API entrypoint' do
    res = get({:accept => :xml})
    version = xml_response(res).root[:version]
    version.wont_be_nil
    version.must_equal API_VERSION
  end

  it 'advertise the current API version in HTTP headers' do
    res = get
    res.headers[:server].must_equal "Apache-Deltacloud/#{API_VERSION}"
  end

  it 'must include the ETag in HTTP headers' do
    res = get
    res.headers[:etag].wont_be_nil
  end

  it 'advertise collections in API entrypoint' do
    res = get({:accept => :xml})
    xml_response(res).xpath('//api/link').wont_be_empty
  end

  it 'include the :href and :rel attribute for each collection in API entrypoint' do
    xml_response(get({:accept => :xml})).xpath("//api/link").each do |collection|
      collection[:href].wont_be_nil
      collection[:rel].wont_be_nil
    end
  end

  it 'uses the absolute URI in the :href attribute for each collection in API entrypoint' do
    xml_response(get({:accept => :xml})).xpath("//api/link").each do |collection|
      collection[:href].must_match /^http/
    end
  end

  it 'advertise features for some collections in API entrypoint' do
    xml_doc = xml_response(get({:accept => :xml}))
    xml_doc.xpath("//api/link/feature").wont_be_empty
  end

  it 'advertise the name of the feature for some collections in API entrypoint' do
    xml_response(get({:accept => :xml})).xpath("//api/link/feature").each do |feature|
      feature[:name].wont_be_nil
    end
  end

  it 'must change the media type from XML to JSON using Accept headers' do
    res = get({:accept => :json})
    res.headers[:content_type].must_equal 'application/json'
  end

  it 'must change the media type to JSON using the "?format" parameter in URL' do
    res = get({}, "?format=json")
    res.headers[:content_type].must_equal 'application/json'
  end

  it 'must change the driver when using X-Deltacloud-Driver HTTP header' do
    res = xml_response(get({'X-Deltacloud-Driver'=> 'ec2', :accept=> :xml}))
    res.root[:driver].must_equal 'ec2'
    res = xml_response(get({'X-Deltacloud-Driver'=> 'mock', :accept=> :xml}))
    res.root[:driver].must_equal 'mock'
  end

  it 'must change the features when driver is swapped using HTTP headers' do
    res = xml_response(get({'X-Deltacloud-Driver'=> 'ec2', :accept=> :xml}))
    # The 'user_name' feature is not supported currently for the EC2 driver
    (res/'api/link/feature').map { |f| f[:name] }.wont_include 'user_name'
    res = xml_response(get({'X-Deltacloud-Driver'=> 'mock', :accept=> :xml}))
    # But it's supported in Mock driver
    (res/'api/link/feature').map { |f| f[:name] }.must_include 'user_name'
  end

  it 'must re-validate the driver credentials when using "?force_auth" parameter in URL' do
    proc {get({ :params => {:force_auth => '1'} })}.must_raise RestClient::Request::Unauthorized
    res = get({ "X-Deltacloud-Driver"=>"mock", :params=>{:force_auth => '1'}, :Authorization=>"Basic #{Base64.encode64('mockuser:mockpassword')}" })
    res.code.must_equal 200
  end

  it 'must change the API PROVIDER using the /api;provider matrix parameter in URI' do
    res = xml_response(get({}, ';provider=test1'))
    res.root[:provider].wont_be_nil
    res.root[:provider].must_equal 'test1'
    res = xml_response(get({}, ';provider=test2'))
    res.root[:provider].must_equal 'test2'
  end

  it 'must change the API DRIVER using the /api;driver matrix parameter in URI' do
    res = xml_response(get({}, ';driver=ec2'))
    res.root[:driver].must_equal 'ec2'
    res = xml_response(get({}, ';driver=mock'))
    res.root[:driver].must_equal 'mock'
  end

end
