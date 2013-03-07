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

module Deltacloud::Client
  module Helpers
    module XmlHelper

      # Extract XML string from the various objects
      #
      def extract_xml_body(obj)
        case obj
        when Faraday::Response then obj.body
        when Nokogiri::XML::Element then obj.to_s
        when Nokogiri::XML::Document then obj.to_s
        else obj
        end
      end

    end
  end
end
