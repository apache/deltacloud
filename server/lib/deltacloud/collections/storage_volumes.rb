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
  class StorageVolumes < Base

    include Deltacloud::Features

    set :capability, lambda { |m| driver.respond_to? m }
    check_features :for => lambda { |c, f| driver.class.has_feature?(c, f) }

    new_route_for(:storage_volumes)

    get "/storage_volumes/:id/attach_instance" do
      @instances = driver.instances(credentials, :storage_id => params[:id])
      respond_to do |format|
        format.html{ haml :"storage_volumes/attach", :locals => { :instances=> @instances }}
      end
    end

    collection :storage_volumes do

      standard_index_operation
      standard_show_operation

      operation :create, :with_capability => :create_storage_volume do
        param :snapshot_id, :string,  :optional
        param :capacity,    :string,  :optional
        param :realm_id,    :string,  :optional
        param :name,        :string,  :optional
        param :description, :string,  :optional
        control do
          @storage_volume = driver.create_storage_volume(credentials, params)
          status 201
          response['Location'] = storage_volume_url(@storage_volume.id)
          respond_to do |format|
            format.xml  { haml :"storage_volumes/show", :locals => { :storage_volume => @storage_volume } }
            format.html { haml :"storage_volumes/show", :locals => { :storage_volume => @storage_volume } }
            format.json { JSON::dump(:storage_volume => @storage_volume.to_hash(self)) }
          end
        end
      end

      action :attach, :with_capability => :attach_storage_volume do
        param :id, :string, :required
        param :instance_id,:string,  :required
        param :device,     :string,  :required
        control do
          @storage_volume = driver.attach_storage_volume(credentials, params)
          status 202
          respond_to do |format|
            format.html { redirect(storage_volume_url(params[:id]))}
            format.xml  { haml :"storage_volumes/show", :locals => { :storage_volume => @storage_volume } }
            format.json { JSON::dump(:storage_volume => @storage_volume.to_hash(self)) }
          end
        end
      end

      action :detach, :with_capability => :detach_storage_volume do
        param :id, :string, :required
        control do
          volume = driver.storage_volume(credentials, :id => params[:id])
          @storage_volume =  driver.detach_storage_volume(credentials, :id => volume.id,
                                                          :instance_id => volume.instance_id,
                                                          :device => volume.device)
          status 202
          respond_to do |format|
            format.html { redirect(storage_volume_url(params[:id]))}
            format.xml  { haml :"storage_volumes/show", :locals => { :storage_volume => @storage_volume } }
            format.json { JSON::dump(:storage_volume => @storage_volume.to_hash(self)) }
          end
        end
      end

      operation :destroy, :with_capability => :destroy_storage_volume do
        control do
          driver.destroy_storage_volume(credentials, params)
          status 204
          respond_to do |format|
            format.xml
            format.json
            format.html { redirect(storage_volumes_url) }
          end
        end
      end

    end
  end
end
