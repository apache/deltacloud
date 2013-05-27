#
# Copyright (C) 2009  RimuHosting Ltd
# Author: Ivan Meredith <ivan@ivan.net.nz>
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

module Deltacloud::Drivers::RimuHosting

  class RimuHostingClient
    def initialize(credentials ,baseuri = 'https://rimuhosting.com/r')
      @uri = URI.parse(baseuri)
      @service = Net::HTTP.new(@uri.host, @uri.port)
      @service.use_ssl = true
      @auth = "rimuhosting apikey=#{credentials.password}"
    end

    def request(resource, data='', method='GET')
      headers = {"Accept" => "application/json", "Content-Type" => "application/json"}
      if(!@auth.nil?)
        headers["Authorization"] = @auth
      end
      safely do
        r = @service.send_request(method, @uri.path + resource, data, headers)
        res = JSON.parse(r.body)
        res = res[res.keys[0]]

        if(res['response_type'] == "ERROR" and ( (res['error_info']['error_class'] == "PermissionException") or 
                                                (res['error_info']['error_class'] == "LoginRequired") ))
          raise "AuthFailure"
        end
        res
      end

      def list_images
        request('/distributions')["distro_infos"]
      end

      def list_plans
        request('/pricing-plans;server-type=VPS')["pricing_plan_infos"]
      end

      def list_nodes
        request('/orders;include_inactive=N')["about_orders"]
      end

      def set_server_state(id, state)
        json = {"reboot_request" => {"running_state" => state}}.to_json
        request("/orders/order-#{id}-a/vps/running-state", json, 'PUT')
      end

      def delete_server(id)
        request("/orders/order-#{id}-a/vps",'', 'DELETE')
      end

      def create_server(image_id, plan_code, name)
        json = {:new_vps => {:instantiation_options => {:domain_name => name, :distro => image_id},
                             :pricing_plan_code => plan_code}}.to_json
        request('/orders/new-vps',json, 'POST')[:about_order]
      end
    end

  end
end
