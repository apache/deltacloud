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
  class Images < Base

    include Deltacloud::Features

    check_features :for => lambda { |c, f| driver.class.has_feature?(c, f) }
    set :capability, lambda { |m| driver.respond_to? m }

    new_route_for :images do
      halt 404 unless params[:instance_id]
      @opts[:instance] = Deltacloud::Instance.new( :id => params[:instance_id] )
    end

    collection :images do
      description "Within a cloud provider a realm represents a boundary containing resources"

      operation :index, :with_capability => :images do
        param :architecture,  :string,  :optional
        control { filter_all(:images) }
      end

      operation :show, :with_capability => :image do
        control { show(:image) }
      end

      operation :create, :with_capability => :create_image do
        param :instance_id, :string, :required
        control do
          @image = driver.create_image(credentials, {
            :id => params[:instance_id],
            :name => params[:name],
            :description => params[:description]
          })
          status 201  # Created
          response['Location'] = image_url(@image.id)
          respond_to do |format|
            format.xml  { haml :"images/show", :locals => { :image => @image } }
            format.json { JSON::dump(:image => @image.to_hash(self)) }
            format.html { haml :"images/show", :locals => { :image => @image } }
          end
        end
      end

      operation :destroy, :with_capability => :destroy_image do
        control do
          driver.destroy_image(credentials, params[:id])
          respond_to do |format|
            format.xml { status 204 }
            format.json { status 204 }
            format.html { redirect(images_url) }
          end
        end
      end

    end

  end
end
