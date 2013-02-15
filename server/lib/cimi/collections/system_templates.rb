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
  class SystemTemplates < Base

    set :capability, lambda { |m| driver.respond_to? m }

    collection :system_templates do

      operation :index, :with_capability => :system_templates do
        description "List all system templates"
        control do
          system_templates = CIMI::Model::SystemTemplate.list(self).select_by(params['$select'])
          respond_to do |format|
            format.xml { system_templates.to_xml }
            format.json { system_templates.to_json }
          end
        end
      end

      operation :show, :with_capability => :system_templates do
        description "Show specific system template"
        control do
          system_template = CIMI::Model::SystemTemplate.find(params[:id], self)
          respond_to do |format|
            format.xml { system_template.to_xml }
            format.json { system_template.to_json }
          end
        end
      end

      operation :create, :with_capability => :create_system_template do
        description "Create new system template"
        control do
          if grab_content_type(request.content_type, request.body) == :json
            new_system_template = CIMI::Model::SystemTemplate.create_from_json(request.body.read, self)
          else
            new_system_template = CIMI::Model::SystemTemplate.create_from_xml(request.body.read, self)
          end
          headers_for_create new_system_template
          respond_to do |format|
            format.json { new_system_template.to_json }
            format.xml { new_system_template.to_xml }
          end
        end
      end

      operation :destroy, :with_capability => :destroy_system_template do
        description "Delete a specified system template"
        control do
          CIMI::Model::SystemTemplate.delete!(params[:id], self)
          no_content_with_status(200)
        end
      end

    end

  end
end
