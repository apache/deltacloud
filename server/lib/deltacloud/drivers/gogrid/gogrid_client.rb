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

require 'open-uri'

module Kernel
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    return result
  end
end

module OpenURI
  def self.without_ssl_verification
    old = ::OpenSSL::SSL::VERIFY_PEER
    suppress_warnings { ::OpenSSL::SSL.const_set :VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE }
    yield
  ensure
    suppress_warnings { ::OpenSSL::SSL.const_set :VERIFY_PEER, old }
  end
end

class GoGridClient

  def initialize(server='https://api.gogrid.com/api',
                 apikey='YOUR API KEY',
                 secret='YOUR SHARED SECRET',
                 format='json',
                 version='1.9')
    @server = server
    @secret = secret
    @default_params = {'format'=>format, 'v'=>version,'api_key' => apikey}
  end

  def getRequestURL(method,params)
    requestURL = @server+'/'+method+'?'
    call_params = @default_params.merge(params)
    call_params['sig']=getSignature(@default_params['api_key'],@secret)
    requestURL = requestURL+encode_params(call_params)
  end

  def getSignature(key,secret)
    Digest::MD5.hexdigest(key+secret+"%.0f"%Time.now.to_f)
  end

  def sendAPIRequest(method,params={})
    OpenURI.without_ssl_verification do
      open(getRequestURL(method,params)).read
    end
  end

  def request(method, params={}, version=nil)
    if version
      @default_params['v'] = version
    else
      @default_params['v'] = '1.9'
    end
    request = sendAPIRequest(method, params)
    JSON::parse(request)
  end

  def encode_params(params)
    params.map {|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join("&")
  end

end
