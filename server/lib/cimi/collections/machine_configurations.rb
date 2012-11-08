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
  class MachineConfigurations < Base

    set :capability => lambda { |m| driver.respond_to? m }

    collection :machine_configurations do
      description 'List all machine configurations'

      operation :index, :with_capability => :hardware_profiles do
        description "List all machine configurations"
        control do
          machine_configs = MachineConfiguration.list(self).filter_by(params['$select'])
          respond_to do |format|
            format.xml { machine_configs.to_xml }
            format.json { machine_configs.to_json }
          end
        end
      end

      operation :show, :with_capability => :hardware_profile do
        control do
          machine_conf = MachineConfiguration.find(params[:id], self)
          respond_to do |format|
            format.xml { machine_conf.to_xml }
            format.json { machine_conf.to_json }
          end
        end

      end
    end

  end
end
