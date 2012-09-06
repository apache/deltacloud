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
  class Addresses < Base

    set :capability, lambda { |m| driver.respond_to? m }

    get route_for('/addresses/:id/associate') do
      @address = driver.address(credentials, params )
      @instances = driver.instances(credentials)
      respond_to do |format|
        format.html {haml :"addresses/associate"}
      end
    end

    collection :addresses do
      description "Pool of IP addresses allocated in cloud provider"

      standard_index_operation
      standard_show_operation

      operation :create, :with_capability => :create_address do
        description "Acquire a new IP address for use with your account."
        control do
          @address = driver.create_address(credentials, {})
          status 201    # Created
          response['Location'] = address_url(@address.id)
          respond_to do |format|
            format.xml  { haml :"addresses/show", :ugly => true }
            format.html { haml :"addresses/_address", :layout => false }
            format.json { xml_to_json("addresses/show") }
          end
        end
      end

      operation :destroy, :with_capability => :destroy_address do
        control do
          driver.destroy_address(credentials, { :id => params[:id]})
          status 204
          respond_to do |format|
            format.xml
            format.json
            format.html { redirect(addresses_url) }
          end
        end
      end

      action :associate, :with_capability => :associate_address do
        description "Associate an IP address to an instance"
        param :instance_id, :string, :required
        control do
          driver.associate_address(credentials, { :id => params[:id], :instance_id => params[:instance_id]})
          status 202   # Accepted
          respond_to do |format|
            format.xml
            format.json
            format.html { redirect(address_url(params[:id])) }
          end
        end
      end

      action :disassociate, :with_capability => :associate_address do
        description "Disassociate an IP address from an instance"
        control do
          driver.disassociate_address(credentials, { :id => params[:id] })
          status 202   # Accepted
          respond_to do |format|
            format.xml
            format.json
            format.html { redirect(address_url(params[:id])) }
          end
        end
      end

    end

  end
end
