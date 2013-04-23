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
  class CloudEntryPoint < Base

    get '/' do
      redirect url('/cloudEntryPoint'), 301
    end

    collection :cloudEntryPoint do
      description 'Cloud entry point'
      operation :index do
        description "list all resources of the cloud"
        control do
          if params[:force_auth]
            halt 401 unless driver.valid_credentials?(credentials)
          end
          entry_point = CIMI::Service::CloudEntryPoint.new(self)
          respond_to do |format|
            format.xml { entry_point.to_xml }
            format.json { entry_point.to_json }
          end
        end
      end
    end

  end
end
