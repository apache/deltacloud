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
  class Volumes < Base

    check_capability :for => lambda { |m| driver.respond_to? m }
    collection :volumes do

      operation :index do
        description "List all volumes"
        param :CIMISelect,  :string,  :optional
        control do
          volumes = VolumeCollection.default(self).filter_by(params[:CIMISelect])
          respond_to do |format|
            format.xml { volumes.to_xml }
            format.json { volumes.to_json }
          end
        end
      end

      operation :show do
        description "Show specific Volume."
        control do
          volume = Volume.find(params[:id], self)
          if volume
            respond_to do |format|
              format.xml  { volume.to_xml  }
              format.json { volume.to_json }
            end
          else
            report_error(404)
          end
        end
      end

      operation :create do
        description "Create a new Volume."
        control do
          content_type = (request.content_type.end_with?("+json") ? :json  : :xml)
          #((request.content_type.end_with?("+xml")) ? :xml : report_error(415) ) FIXME
          case content_type
          when :json
            new_volume = Volume.create_from_json(request.body.read, self)
          when :xml
            new_volume = Volume.create_from_xml(request.body.read, self)
          end
          respond_to do |format|
            format.json { new_volume.to_json }
            format.xml { new_volume.to_xml }
          end
        end
      end

      operation :destroy do
        description "Delete a specified Volume"
        param :id, :string, :required
        control do
          Volume.delete!(params[:id], self)
          no_content_with_status(200)
        end
      end

    end


  end
end
