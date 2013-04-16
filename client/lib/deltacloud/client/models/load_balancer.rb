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
  class LoadBalancer < Base

    include Deltacloud::Client::Methods::LoadBalancer

    attr_reader :created_at
    attr_reader :realm_id
    attr_reader :public_addresses
    attr_reader :actions
    attr_reader :listeners
    attr_reader :instances

    # LoadBalancer model methods
    #
    # def reboot!
    #   load_balancer_reboot(_id)
    # end

    # Parse the LoadBalancer entity from XML body
    #
    # - xml_body -> Deltacloud API XML representation of the load_balancer
    #
    def self.parse(xml_body)
      {
        :created_at => xml_body.text_at(:created_at),
        :realm_id => xml_body.attr_at('realm', :id),
        :actions => xml_body.xpath('actions/link').map { |a| a['rel'].to_sym },
        :public_addresses => xml_body.xpath('public_addresses/address').map { |a| a.text.strip },
        :listeners => xml_body.xpath('listeners/listener').map { |l|
          {
            :protocol => l[:protocol],
            :load_balancer_port => l.text_at(:load_balancer_port),
            :instance_port => l.text_at(:instance_port)
          }
        },
        :instances => xml_body.xpath('instances/instance').map { |i| i[:id] }
      }
    end
  end
end
