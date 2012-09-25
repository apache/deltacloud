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

module CIMI::Collections
  class Addresses < Base

    set :capability, lambda { |m| driver.respond_to? m }

    collection :addresses do

      description 'An Address represents an IP address, and its associated metdata, for a particular Network.'

      operation :index, :with_capability => :addresses do
        description 'List all Addresses in the AddressCollection'
        param :CIMISelect, :string, :optional
        control do
          addresses = Address.list(self).filter_by(params[:CIMISelect])
          respond_to do |format|
            format.xml {addresses.to_xml}
            format.json {addresses.to_json}
          end
        end
      end

      operation :show, :with_capability => :address do
        description 'Show a specific Address'
        control do
          address = CIMI::Model::Address.find(params[:id], self)
          respond_to do |format|
            format.xml {address.to_xml}
            format.json {address.to_json}
          end
        end
      end

      operation :create, :with_capability => :create_address do
        description "Create a new Address"
        control do
          if request.content_type.end_with?("json")
            address = CIMI::Model::Address.create(request.body.read, self, :json)
          else
            address = CIMI::Model::Address.create(request.body.read, self, :xml)
          end
          respond_to do |format|
            format.xml { address.to_xml }
            format.json { address.to_json }
          end
        end
      end

      operation :destroy, :with_capability => :delete_address do
        description "Delete a specified Address"
        param :id, :string, :required
        control do
          CIMI::Model::Address.delete!(params[:id], self)
          no_content_with_status(200)
        end
      end

    end

  end
end
