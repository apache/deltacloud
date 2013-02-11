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
  class Credentials < Base

    set :capability, lambda { |m| driver.respond_to? m }

    collection :credentials do
      description 'Machine Admin entity'

      operation :index, :with_capability => :keys do
        description "List all machine admins"
        control do
          credentials = Credential.list(self).select_by(params['$select'])
          respond_to do |format|
            format.xml { credentials.to_xml }
            format.json { credentials.to_json }
          end
        end
      end

      operation :show, :with_capability => :key do
        description "Show specific machine admin"
        control do
          credential = Credential.find(params[:id], self)
          respond_to do |format|
            format.xml { credential.to_xml }
            format.json { credential.to_json }
          end
        end
      end

      operation :create, :with_capability => :create_key do
        description "Show specific machine admin"
        control do
          if current_content_type == :json
            new_admin = Credential.create_from_json(request.body.read, self)
          else
            new_admin = Credential.create_from_xml(request.body.read, self)
          end
          headers_for_create new_admin
          respond_to do |format|
            format.json { new_admin.to_json }
            format.xml { new_admin.to_xml }
          end
        end
      end

      operation :delete, :with_capability => :destroy_key do
        description "Delete specified Credential entity"
        control do
          Credential.delete!(params[:id], self)
          no_content_with_status(200)
        end
      end

    end

  end
end
