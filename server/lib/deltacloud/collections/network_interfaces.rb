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
  class NetworkInterfaces < Base

    include Deltacloud::Features

    set :capability, lambda { |m| driver.respond_to? m }
    check_features :for => lambda { |c, f| driver.class.has_feature?(c, f) }
    new_route_for(:network_interfaces) do
      @opts={}
      @opts[:instances]=driver.instances(credentials)
      @opts[:networks]= driver.respond_to?(:subnets) ? driver.subnets(credentials) : driver.networks(credentials)
    end

    collection :network_interfaces do

      standard_show_operation({:check => :subnets})
      standard_index_operation({:check => :subnets})

      operation :create, :with_capability => :create_network_interface do
        param :instance,   :string,  :required
        param :network,     :string,  :required
        param :name,          :string,  :optional
        control do
          params.delete("name") if params["name"] && params["name"].empty?
          @network_interface = driver.create_network_interface(credentials, params)
          respond_to do |format|
            format.xml  { haml :"network_interfaces/show", :locals => {:network_interface=>@network_interface, :subnets=>driver.respond_to?(:subnets)}}
            format.html { haml :"network_interfaces/show", :locals => {:network_interface=>@network_interface, :subnets=>driver.respond_to?(:subnets)}}
            format.json { JSON::dump(:network_interface => @network_interface.to_hash(self))}
          end
        end
      end

      operation :destroy, :with_capability => :destroy_network_interface do
        control do
          driver.destroy_network_interface(credentials, params[:id])
          status 204
          respond_to do |format|
            format.xml
            format.json
            format.html { redirect(network_interfaces_url) }
          end
        end
      end

    end

  end
end
