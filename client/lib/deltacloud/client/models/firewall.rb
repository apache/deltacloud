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
  class Firewall < Base

    include Deltacloud::Client::Methods::Common
    include Deltacloud::Client::Methods::Firewall

    # Inherited attributes: :_id, :name, :description

    # Custom attributes:
    #
    attr_reader :owner_id
    attr_reader :rules

    # Parse the Firewall entity from XML body
    #
    # - xml_body -> Deltacloud API XML representation of the firewall
    #
    def self.parse(xml_body)
      {
        :owner_id => xml_body.text_at(:owner_id),
        :rules => xml_body.xpath('rules/rule').map { |rule|
          Rule.convert(self, rule)
        }
      }
    end

    class Rule < Deltacloud::Client::Base

      attr_reader :allow_protocol
      attr_reader :port_from
      attr_reader :port_to
      attr_reader :direction
      attr_reader :sources

     def self.parse(xml_body)
       {
        :allow_protocol => xml_body.text_at(:allow_protocol),
        :port_from => xml_body.text_at(:port_from),
        :port_to => xml_body.text_at(:port_to),
        :direction => xml_body.text_at(:direction),
        :sources => xml_body.xpath('sources/source').map { |s|
          { :name => s['name'], :owner => s['owner'], :type => s['type'] }
        }
       }
     end

    end
  end
end
