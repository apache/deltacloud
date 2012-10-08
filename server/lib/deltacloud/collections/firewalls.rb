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

module Deltacloud::Collections
  class Firewalls < Base

    include Deltacloud::Features

    set :capability, lambda { |m| driver.respond_to? m }

    check_features :for => lambda { |c, f| driver.class.has_feature?(c, f) }

    get '/firewalls/:id/new_rule' do
      @firewall_name = params[:id]
      respond_to do |format|
        format.html {haml :"firewalls/new_rule" }
      end
    end

    new_route_for :firewalls

    collection :firewalls do
      description "Allow user to define firewall rules for an instance (ec2 security groups) eg expose ssh access [port 22, tcp]."

      collection :rules, :with_id => :rule_id, :no_member => true do

        operation :destroy, :with_capability => :delete_firewall_rule do
          control do
            opts = {}
            opts[:firewall] = params[:id]
            opts[:rule_id] = params[:rule_id]
            driver.delete_firewall_rule(credentials, opts)
            status 204
            respond_to do |format|
              format.xml
              format.json
              format.html {redirect firewall_url(params[:id])}
            end
          end
        end

      end

      standard_show_operation
      standard_index_operation

      operation :create, :with_capability => :create_firewall do
        param :name,          :string,    :required
        param :description,   :string,    :required
        control do
          @firewall = driver.create_firewall(credentials, params )
          status 201  # Created
          response['Location'] = firewall_url(@firewall.id)
          respond_to do |format|
            format.xml  { haml :"firewalls/show" }
            format.html { haml :"firewalls/show" }
            format.json { xml_to_json("firewalls/show") }
          end
        end
      end

      operation :destroy, :with_capability => :delete_firewall do
        control do
          driver.delete_firewall(credentials, params)
          status 204
          respond_to do |format|
            format.xml
            format.json
            format.html {  redirect(firewalls_url) }
          end
        end
      end

      action :rules, :with_capability => :create_firewall_rule do
        param :protocol,  :required, :string, ['tcp','udp','icmp'], "Transport layer protocol for the rule"
        param :port_from, :required, :string, [], "Start of port range for the rule"
        param :port_to,   :required, :string, [], "End of port range for the rule"
        control do
          #source IPs from params
          addresses =  params.inject([]){|result,current| result << current.last unless current.grep(/^ip[-_]address/i).empty?; result}
          #source groups from params
          groups = {}
          max_groups  = params.select{|k,v| k=~/^group/}.size/2
          for i in (1..max_groups) do
            groups.merge!({params["group#{i}"]=>params["group#{i}owner"]})
          end
          params['addresses'] = addresses
          params['groups'] = groups
          if addresses.empty? && groups.empty?
            raise Deltacloud::Exceptions.exception_from_status(
              400, 'No sources. Specify at least one source ip address or group.'
            )
          end
          driver.create_firewall_rule(credentials, params)
          @firewall = driver.firewall(credentials, {:id => params[:id]})
          status 201
          respond_to do |format|
            format.xml  { haml :"firewalls/show" }
            format.html { haml :"firewalls/show" }
            format.json { xml_to_json("firewalls/show") }
          end
        end
      end

    end
  end
end
