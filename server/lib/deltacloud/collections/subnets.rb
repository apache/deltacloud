
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
  class Subnets < Base

    include Deltacloud::Features

    set :capability, lambda { |m| driver.respond_to? m }
    check_features :for => lambda { |c, f| driver.class.has_feature?(c, f) }

    get '/subnets/new' do
      respond_to do |format|
        format.html { haml :"subnets/new" }
      end
    end


    collection :subnets do

      standard_show_operation
      standard_index_operation

      operation :create, :with_capability => :create_subnet do
        param :network_id, :string, :required
        param :address_block,  :string,  :required
        control do
          @subnet = driver.create_subnet(credentials, { :network_id => params[:network_id], :address_block => params[:address_block]})
          respond_to do |format|
            format.xml  { haml :"subnets/show"}
            format.html { haml :"subnets/show" }
            format.json { xml_to_json("subnets/show")}
          end
        end
      end

      operation :destroy, :with_capability => :destroy_subnet do
        control do
          driver.destroy_subnet(credentials, params[:id])
          status 204
          respond_to do |format|
            format.xml
            format.json
            format.html { redirect(subnets_url) }
          end
        end
      end

    end

  end
end
