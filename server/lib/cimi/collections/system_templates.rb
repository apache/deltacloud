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

    post '/system_templates/import' do
      CIMI::Service::SystemTemplateImport.parse(self).import
      no_content_with_status(202)
    end

    collection :system_templates do

      generate_index_operation :with_capability => :system_templates
      generate_show_operation :with_capability => :system_templates
      generate_create_operation :with_capability => :create_system_template
      generate_delete_operation :with_capability => :destroy_system_template

      action :export, :with_capability => :export_system_template do
        description "Export specific system template."
        param :id,          :string,    :required
        control do
          location = CIMI::Service::SystemTemplateExport.parse(self).export(params[:id])
          if location
            header_for_location(location)
          else
            no_content_with_status(202)
            # Handle errors using operation.failure?
          end
        end
      end

    end

  end
end
