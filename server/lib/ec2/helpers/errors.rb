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

module Deltacloud::EC2
  module Errors

    def report_error(code)
      error = (request.env['sinatra.error'] || @exception)
      code = 500 if not code and not error.class.method_defined? :code
      Nokogiri::XML::Builder.new do |xml|
        xml.send(:Response) {
          xml.send(:Errors) {
            xml.send(:Code, error_for_code(code))
            xml.send(:Message, error.respond_to?(:message) ? error.message : '')
          }
          xml.send(:RequestID, request_id)
        }
      end.to_xml
    end

    def request_id
      Digest::MD5.hexdigest("#{request.env['REMOTE_ADDR']}#{request.env['HTTP_USER_AGENT']}#{Time.now.to_i}#{rand(250)}")
    end

    def error_for_code(code)
      case code
        when 401 then 'AuthFailure'
        when 500 then 'InternalError'
        else "Unavailable (#{code})"
      end
    end

  end
end
