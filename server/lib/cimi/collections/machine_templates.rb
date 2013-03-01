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
  class MachineTemplates < Base

    set :capability, lambda { |t| true }

    collection :machine_templates do

      operation :index do
        description "List all machine templates"
        control do
          machine_templates = MachineTemplate.list(self)
          respond_to do |format|
            format.xml { machine_templates.to_xml }
            format.json { machine_templates.to_json }
          end
        end
      end

      operation :show do
        description "Show specific machine template"
        control do
          machine_template = MachineTemplate.find(params[:id], self)
          respond_to do |format|
            format.xml { machine_template.to_xml }
            format.json { machine_template.to_json }
          end
        end
      end

      operation :create do
        description "Create new machine template"
        control do
          mt = MachineTemplateCreate.parse(self)
          new_machine_template = mt.create
          headers_for_create new_machine_template
          respond_to do |format|
            format.json { new_machine_template.to_json }
            format.xml { new_machine_template.to_xml }
          end
        end
      end

      operation :destroy do
        description "Delete a specified machine template"
        control do
          MachineTemplate.delete!(params[:id], self)
          no_content_with_status(200)
        end
      end

    end

  end
end
