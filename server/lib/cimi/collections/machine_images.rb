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
  class MachineImages < Base

    set :capability, lambda { |m| driver.respond_to? m }

    collection :machine_images do
      description 'List all machine images'

      operation :index, :with_capability => :images do
        description "List all machine configurations"
        control do
          machine_images = MachineImage.list(self)
          respond_to do |format|
            format.xml { machine_images.to_xml }
            format.json { machine_images.to_json }
          end
        end
      end

      operation :show, :with_capability => :image do
        description "Show specific machine image."
        control do
          machine_image = MachineImage.find(params[:id], self)
          respond_to do |format|
            format.xml { machine_image.to_xml }
            format.json { machine_image.to_json }
          end
        end
      end

      operation :create, :with_capability => :create_image do
        description "Create a new machine image."
        control do
          mi = MachineImageCreate.parse(self)
          machine_image = mi.create
          headers_for_create machine_image
          respond_to do |format|
            format.xml { machine_image.to_xml }
            format.json { machine_image.to_json }
          end
        end
      end

      operation :destroy, :with_capability => :destroy_image do
        description "Delete a specified MachineImage"
        control do
          MachineImage.delete!(params[:id], self)
          no_content_with_status 200
        end
      end

    end

  end
end
