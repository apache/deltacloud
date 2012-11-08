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
  class NetworkPortTemplates < Base

    set :capability, lambda { |m| driver.respond_to? m }

    collection :network_port_templates do

      description 'The NetworkPort Template is a set of Configuration values for realizing a NetworkPort. A NetworkPort Template may be used to create multiple NetworkPorts'

      operation :index, :with_capability => :network_port_templates do
        description 'List all NetworkPortTemplates in the NetworkPortTemplateCollection'
        control do
          network_port_templates = NetworkPortTemplate.list(self).filter_by(params['$select'])
          respond_to do |format|
            format.xml {network_port_templates.to_xml}
            format.json {network_port_templates.to_json}
          end
        end
      end

      operation :show, :with_capability => :network_port_templates do
        description 'Show a specific NetworkPortTemplate'
        control do
          network_port_template = NetworkPortTemplate.find(params[:id], self)
          respond_to do |format|
            format.xml {network_port_template.to_xml}
            format.json {network_port_template.to_json}
          end
        end
      end

    end

  end
end
