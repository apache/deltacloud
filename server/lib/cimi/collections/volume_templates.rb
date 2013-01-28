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
  class VolumeTemplates < Base

    set :capability, lambda { |m| driver.respond_to? m }

    collection :volume_templates do

      operation :index, :with_capability => :storage_volumes do
        description "Retrieve the Volume Template Collection"
        control do
          volume_template = VolumeTemplate.list(self).select_by(params['$select'])
          respond_to do |format|
            format.xml { volume_template.to_xml }
            format.json { volume_template.to_json }
          end
        end
      end

      operation :show, :with_capability => :storage_volume do
        description "Get a specific VolumeTemplate"
        control do
          volume_template = VolumeTemplate.find(params[:id], self)
          respond_to do |format|
            format.xml { volume_template.to_xml }
            format.json { volume_template.json }
          end
        end
      end

      operation :create, :with_capability => :create_storage_volume do
        description "Create new VolumeTemplate"
        control do
          content_type = grab_content_type(request.content_type, request.body)
          new_template = CIMI::Model::VolumeTemplate.create(request.body.read, self, content_type)
          headers_for_create new_template
          respond_to do |format|
            format.json { new_template.to_json }
            format.xml { new_template.to_xml }
          end
        end
      end

      operation :destroy, :with_capability => :destroy_storage_volume do
        description "Delete a specified VolumeTemplate"
        control do
          CIMI::Model::VolumeTemplate.delete!(params[:id], self)
          no_content_with_status(200)
        end
      end

    end

  end
end
