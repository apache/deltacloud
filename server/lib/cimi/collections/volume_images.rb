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
  class VolumeImages < Base

    set :capability, lambda { |m| driver.respond_to? m }

    collection :volume_images do
      description 'This entity represents an image that could be place on a pre-loaded volume.'

      operation :index, :with_capability => :storage_snapshots do
        description "List all volumes images"
        param :CIMISelect,  :string,  :optional
        control do
          volume_images = VolumeImageCollection.default(self).filter_by(params[:CIMISelect])
          respond_to do |format|
            format.xml { volume_images.to_xml }
            format.json { volume_images.to_json }
          end
        end
      end

      operation :show, :with_capability => :storage_snapshot do
        description "Show a specific volume image"
        control do
          volume_image = VolumeImage.find(params[:id], self)
          respond_to do |format|
            format.xml { volume_image.to_xml }
            format.json { volume_image.to_json }
          end
        end
      end
    end


  end
end
